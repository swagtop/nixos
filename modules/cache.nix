{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.swag.cache;
in
{
  options = {
    swag.cache = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      mode = lib.mkOption {
        type = lib.types.enum [
          "use"
          "host"
        ];
        default = "use";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.mode == "use") {
        nix.settings = {
          substituters = lib.mkForce [
            "https://cache.spirre.vip"
            "https://cache.nixos.org"
          ];

          trusted-public-keys = [
            "cache.spirre.vip:jnYuXaQxsp5/9SWHeeCzVYVmYs6xXgl5/5LXnDJ+WbU="
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ];
        };

        nix.extraOptions = ''
          fallback = true
        '';

        systemd.services.pull-system-flake = {
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];

          serviceConfig = {
            Type = "oneshot";
            User = "root";
            WorkingDirectory = "/etc/nixos";
            ExecStart = pkgs.writeShellScript "pull-system-flake" ''
              GIT_PULL_RESULT=$(${pkgs.git}/bin/git pull --ff-only)
              if [[ $GIT_PULL_RESULT != "Already up to date." ]]; then
                ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake /etc/nixos
              fi
            '';

            # Setting this service to be nicer, for less prominent background updates.
            # https://positron.solutions/articles/building-nicely-with-rust-and-nix
            Nice = 18;
            IOSchedulingClass = "idle";
            IOSchedulingPriority = 7;
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
          enable = true;
          secretKeyFile = "/var/lib/nixos/cache-priv-key.pem";
        };

        systemd.services.update-system-flake = {
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];

          restartIfChanged = false;

          serviceConfig = {
            Type = "oneshot";
            User = "root";
            WorkingDirectory = "/etc/nixos";
            ExecStart =
              pkgs.writeShellApplication {
                name = "update-system-flake";
                runtimeInputs = with pkgs; [
                  coreutils
                  git
                  nix
                  nixos-rebuild
                  systemd
                ];
                bashOptions = [ ];
                text =
                  let
                    nixosSystemsToBuild = [
                      "gamebeast"
                      "servtop"
                    ];
                  in
                  ''
                    printf "" > /srv/f/cache-log.txt # Clear log at beginning of service.

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
                    ${pkgs.nix}/bin/nix flake update
                    echo

                    ${builtins.concatStringsSep "\n" (
                      map (s: ''
                        # Skip building system if it is not using the cache.
                        if [[ $(nix eval .#nixosConfigurations.${s}.config.swag.cache.enable) == "false" ]]; then
                          continue
                        fi
                        echo "$(date '+%H:%M') Building '${s}'"
                        echo "================${lib.concatMapStrings (_: "=") (lib.range 0 (builtins.stringLength s))}"
                        ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake .#${s} --no-link -j 1
                        echo
                      '') nixosSystemsToBuild
                    )}

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
              }
              + "/bin/update-system-flake";

            # Setting this service to be nicer, to let other services this server take
            # the reins when needed. This can run all day no problem.
            # https://positron.solutions/articles/building-nicely-with-rust-and-nix
            Nice = 18;
            IOSchedulingClass = "idle";
            IOSchedulingPriority = 7;

            StandardOutput = "file:/srv/f/cache-log.txt";
            # StandardError = "file:/srv/f/cache-log.txt";
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
