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
      ExecStart = pkgs.writeShellScript "rebuild" ''
        ${pkgs.git}/bin/git pull --ff-only || echo 'Failed git pull!'
        ${pkgs.nix}/bin/nix flake update
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .
        DATE="$(date '+%Y-%m-%d')"
        ${pkgs.git}/bin/git commit -m '$DATE Automatic lockfile update.' flake.lock
        ${pkgs.git}/bin/git push
      '';
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
