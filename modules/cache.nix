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

      publicKey = lib.mkOption {
        type = lib.types.str;
        default = "cache.spirre.vip:jnYuXaQxsp5/9SWHeeCzVYVmYs6xXgl5/5LXnDJ+WbU=";
      };

      secretKeyFile = lib.mkOption {
        type = lib.types.externalPath;
        default = "/var/lib/nixos/cache-priv-key.pem";
      };

      cacheLogFile = lib.mkOption {
        type = lib.types.externalPath;
        default = "/srv/f/cache-log.txt";
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
          WorkingDirectory = "/etc/nixos";
          ExecStart = pkgs.writeShellScript "pull-system-flake" ''
            GIT_PULL_RESULT=$(${pkgs.git}/bin/git pull --ff-only)
            if [[ $GIT_PULL_RESULT != "Already up to date." ]]; then
              ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake /etc/nixos
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
              git
              jq
              nix
              nixos-rebuild
              systemd
            ];
            bashOptions = [ ];
            text = ''
              printf "" > "${cfg.cacheLogFile}" # Clear log at beginning of service.

              # https://discourse.nixos.org/t/ssl-cert-file-and-connection-issues-in-nix-shells/7856
              export SSL_CERT_FILE="/etc/ssl/certs/ca-bundle.crt"

              echo "$(date '+%Y-%m-%d @ %H:%M') Beginning update"
              printf "===================================\n\n"
              # Making sure this service can run, by stopping any lingering rebuilds.
              ${pkgs.systemd}/bin/systemctl stop nixos-rebuild-switch-to-configuration.service 2>&1 /dev/null
              echo

              echo "$(date '+%H:%M') Pulling repository"
              echo "========================"
              ${pkgs.git}/bin/git pull --ff-only || echo 'Failed git pull!'
              echo

              FLAKE_INPUTS_UPDATE_DATE=$(date '+%Y-%m-%d')
              echo "$(date '+%H:%M') Updating flake inputs"
              echo "==========================="
              ${pkgs.nix}/bin/nix flake update --flake .
              echo

              allSystems=$(
                nix eval --raw .#nixosConfigurations --apply \
                  'i: builtins.concatStringsSep "\n" (builtins.attrNames i) + "\n"'
              )

              declare -a buildSystems=()
              declare -a noBuildSystems=()

              for system in $allSystems; do
                if [[ $(nix eval .#nixosConfigurations."$system".config.swag.cache.enable --quiet) == "true" ]]; then
                  buildSystems+=("$system")
                else
                  noBuildSystems+=("$system")
                fi
              done

              echo
              echo "Building the following hosts"
              echo "============================"
              printf "%s\n" "''${buildSystems[@]}"

              echo
              echo "Not building the following hosts"
              echo "================================"
              printf "%s\n" "''${noBuildSystems[@]}"
              echo

              for system in "''${buildSystems[@]}"; do
                # Skip building system if it is not using the cache.
                echo "$(date '+%H:%M') Building '$system'"
                echo "================"
                ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake .#"$system" --no-link -j 1
                echo
              done

              echo "$(date '+%H:%M') Rebuilding and switching"
              echo "=============================="
              ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .
              echo

              echo "$(date '+%H:%M') Committing lockfile and pushing"
              echo "====================================="
              ${pkgs.git}/bin/git commit -m "$FLAKE_INPUTS_UPDATE_DATE Automatic lockfile update." flake.lock || true
              ${pkgs.git}/bin/git push
              echo

              echo "$(date '+%H:%M') Finished update"
              echo "====================="
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
            WorkingDirectory = "/etc/nixos";
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
