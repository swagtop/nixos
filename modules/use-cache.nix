{ lib, pkgs, ... }:
{
  nix.settings = {
    substituters = lib.mkForce [
      "https://cache.spirre.vip?priority=1"
      "https://cache.nixos.org?priority=2"
    ];
    trusted-public-keys = [
      "cache.spirre.vip:jnYuXaQxsp5/9SWHeeCzVYVmYs6xXgl5/5LXnDJ+WbU="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

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
      Nice = 15;
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
}
