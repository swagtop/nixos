{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.swag.cache;

  # Setting services to be nicer, for less disruptive background updates.
  # https://positron.solutions/articles/building-nicely-with-rust-and-nix
  niceService = {
    Nice = 18;
    IOSchedulingClass = "idle";
    IOSchedulingPriority = 7;
  };
in
{
  options = {
    swag.cache = {
      enable = lib.mkEnableOption "Opt into the swag cache system.";

      mode = lib.mkOption {
        type = lib.types.enum [
          "user"
          "host"
        ];
        default = "user";
      };

      url = lib.mkOption {
        type = lib.types.str;
        default = "https://cache.spirre.vip";
      };

      # The publickey generated here is made like so:
      # 'nix-store --generate-binary-cache-key cache.spirre.vip /var/lib/nixos/cache-priv-key.pem public'.
      # ... where the 'public' file contains the 'default' value below.
      publicKey = lib.mkOption {
        type = lib.types.str;
        default = "cache.spirre.vip:jnYuXaQxsp5/9SWHeeCzVYVmYs6xXgl5/5LXnDJ+WbU=";
      };

      # The public key file here is generated together with the public key in
      # the command above. Path can be anywhere, here it is placed in a
      # directory with no read permission for anyone but the 'nix-serve' user.
      # This is achieved like so:
      # 'KEY_PATH=/var/lib/nixos/cache-priv-key.pem'
      # 'chown "$KEY_PATH" nix-serve'
      # 'chmod 400 "$KEY_PATH"'
      secretKeyFile = lib.mkOption {
        type = lib.types.externalPath;
        default = "/var/lib/nixos/cache-priv-key.pem";
      };

      cacheLogFile = lib.mkOption {
        type = lib.types.externalPath;
        default = "/srv/f/cache-log.txt";
      };

      flakeDir = lib.mkOption {
        type = lib.types.path;
        default = "/etc/nixos";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.mode == "user") {
      nix.settings = {
        substituters = lib.mkBefore [ cfg.url ];
        trusted-public-keys = lib.mkBefore [ cfg.publicKey ];
      };

      nix.extraOptions = ''
        fallback = true
      '';

      systemd.services.user-nixos-cache-update = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = niceService // {
          Type = "oneshot";
          User = "root";
          WorkingDirectory = cfg.flakeDir;
          ExecStart = pkgs.writeShellScript "pull-system-flake" ''
            GIT_PULL_RESULT=$(${pkgs.git}/bin/git rebase --autostash)
            if [[ $GIT_PULL_RESULT != "Already up to date." ]]; then
              ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${cfg.flakeDir}
            fi
          '';
        };
      };

      systemd.timers.pull-system-flake = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "11:00";
          Persistent = true;
        };
      };
    })

    (lib.mkIf (cfg.enable && cfg.mode == "host") {
      services.nix-serve = {
        inherit (cfg) secretKeyFile;
        enable = true;
      };

      systemd.services.host-nixos-cache-update =
        let
          update-script = pkgs.writeShellApplication {
            name = "update-system-flake";
            runtimeInputs = with pkgs; [
              coreutils
              gawk
              git
              nix
              nixos-rebuild
              systemd
            ];
            bashOptions = [ ];
            text = ''
              printf "" > "${cfg.cacheLogFile}" # Clear log at beginning of service.

              function print-with-underline () {
                echo "$1"
                seq ''${#1} | awk '{ printf "=" }'
                echo
              }

              # https://discourse.nixos.org/t/ssl-cert-file-and-connection-issues-in-nix-shells/7856
              export SSL_CERT_FILE="/etc/ssl/certs/ca-bundle.crt"

              print-with-underline "$(date '+%Y-%m-%d @ %H:%M') Beginning update"
              # Making sure this service can run, by stopping any lingering rebuilds.
              systemctl stop nixos-rebuild-switch-to-configuration.service 2>&1 /dev/null
              echo

              print-with-underline "$(date '+%H:%M') Pulling repository"
              git pull --ff-only || echo 'Failed git pull!'
              echo

              FLAKE_INPUTS_UPDATE_DATE=$(date '+%Y-%m-%d')
              print-with-underline "$(date '+%H:%M') Updating flake inputs"
              nix flake update --flake .
              echo

              allSystems=$(
                nix eval --raw .#nixosConfigurations --apply \
                  'i: builtins.concatStringsSep "\n" (builtins.attrNames i) + "\n"'
              )

              declare -a buildSystems=()
              declare -a noBuildSystems=()

              for system in $allSystems; do
                cacheEnabled=$(nix eval .#nixosConfigurations."$system".config.swag.cache.enable)
                if [[ $cacheEnabled == "true" ]]; then
                  buildSystems+=("$system")
                else
                  noBuildSystems+=("$system")
                fi
              done

              echo
              print-with-underline "Building the following hosts"
              printf "%s\n" "''${buildSystems[@]}"

              echo
              print-with-underline "Ignoring the following hosts"
              printf "%s\n" "''${noBuildSystems[@]}"
              echo

              for system in "''${buildSystems[@]}"; do
                # Skip building system if it is not using the cache.
                print-with-underline "$(date '+%H:%M') Building '$system'"
                nixos-rebuild build --flake .#"$system" --no-link -j 1
                echo
              done

              print-with-underline "$(date '+%H:%M') Rebuilding and switching"
              nixos-rebuild switch --flake .
              echo

              print-with-underline "$(date '+%H:%M') Committing lockfile and pushing"
              git commit -m "$FLAKE_INPUTS_UPDATE_DATE Automatic lockfile update." flake.lock || true
              git push
              echo

              print-with-underline "$(date '+%Y-%m-%d @ %H:%M') Finished update"
            '';
          };
        in
        {
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];

          restartIfChanged = false;

          serviceConfig = niceService // {
            Type = "oneshot";
            User = "root";
            WorkingDirectory = cfg.flakeDir;
            ExecStart = "${update-script}${update-script.destination}";

            StandardOutput = "file:${cfg.cacheLogFile}";
            # StandardError = "file:${cfg.cacheLogFile}";
          };
        };

      systemd.timers.update-system-flake = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          RandomizedOffsetSec = "30m";
          OnCalendar = "12:00";
        };
      };
    })
  ];
}
