{ pkgs, lib, ... }:
{
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
                "cooltop"
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

              echo "$(date '+%H:%M') Updating flake inputs"
              echo "==========================="
              ${pkgs.nix}/bin/nix flake update
              echo

              ${builtins.concatStringsSep "\n" (
                map (s: ''
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
              ${pkgs.git}/bin/git commit -m "$(date '+%Y-%m-%d') Automatic lockfile update." flake.lock || true
              ${pkgs.git}/bin/git push
              echo

              echo "$(date '+%H:%M') Finished update"
              echo "====================="
            '';
        }
        + "/bin/update-system-flake";
      StandardOutput = "file:/srv/f/cache-log.txt";
      # StandardError = "file:/srv/f/cache-log.txt";
    };
  };

  systemd.timers.update-system-flake = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      RandomizedOffsetSec = "30m";
      OnCalendar = "2:37";
    };
  };
}
