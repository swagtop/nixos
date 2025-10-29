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
      ExecStart = pkgs.writeShellScript "update-system-flake" ''
        date '+%Y-%m-%d' # For the log.
        echo "==============="

        echo "$(date '%H:%M') Pulling repository"
        echo "========================"
        ${pkgs.git}/bin/git pull --ff-only || echo 'Failed git pull!'; false
        echo

        echo "$(date '%H:%M') Updating flake inputs"
        echo "==========================="
        ${pkgs.nix}/bin/nix flake update
        echo

        echo "$(date '%H:%M') Rebuilding system"
        echo "======================="
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .
        echo

        echo "$(date '%H:%M') Committing lockfile and pushing"
        echo "======================="
        ${pkgs.git}/bin/git commit -m "$(date '+%Y-%m-%d') Automatic lockfile update." flake.lock
        ${pkgs.git}/bin/git push
        echo
      '';
      StandardOutput = "file:/srv/f/cache-log.txt";
      StandardError = "file:/srv/f/cache-log.txt";
    };
  };

  systemd.timers.update-system-flake = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "2:37";
      Persistent = true;
    };
  };
}
