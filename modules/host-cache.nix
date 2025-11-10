{ pkgs, ... }:
{
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/lib/nixos/cache-priv-key.pem";
  };

  systemd.services.update-system-flake = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      WorkingDirectory = "/etc/nixos";
      ExecStart = pkgs.writeShellApplication {
        name = "update-system-flake";
        runtimeInputs = with pkgs; [ git nix nixos-rebuild ];
        text = ''
          printf "" > /srv/f/cache-log.txt # Clear log at beginning of service.

          echo "$(date '+%Y-%m-%d @ %H:%M') Beginning update"
          printf "===================================\n\n"

          echo "$(date '+%H:%M') Pulling repository"
          echo "========================"
          git pull --ff-only || echo 'Failed git pull!'; false
          echo

          echo "$(date '+%H:%M') Updating flake inputs"
          echo "==========================="
          nix flake update
          echo

          echo "$(date '+%H:%M') Rebuilding system"
          echo "======================="
          nixos-rebuild switch --flake .
          echo

          echo "$(date '+%H:%M') Committing lockfile and pushing"
          echo "====================================="
          git commit -m "$(date '+%Y-%m-%d') Automatic lockfile update." flake.lock
          git push
          echo

          echo "$(date '+%H:%M') Finished update"
          echo "====================="
        '';
      };
      StandardOutput = "file:/srv/f/cache-log.txt";
      StandardError = "file:/srv/f/cache-log.txt";
    };
  };

  systemd.timers.update-system-flake = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      RandomizedOffsetSec = "30m";
      OnCalendar = "2:37";
      Persistent = true;
    };
  };
}
