{ pkgs, ... }:
{
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/lib/nixos/cache-priv-key.pem";
  };

  nix.settings = {
    secret-key-files = [ "/var/lib/nixos/cache-priv-key.pem" ];
  };

  system.autoUpgrade = {
    enable = true;
    upgrade = true;
    flake = "/etc/nixos";
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
      "--commit-lock-file"
    ];
    dates = "03:00";
    randomizedDelaySec = "45min";
  };

  systemd.services.push-system-flake = {
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/etc/nixos";
      ExecStart = pkgs.writeShellScript "rebuild" ''
        ${pkgs.git}/bin/git push
      '';
    };
  };

  systemd.timers.push-system-flake = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "10:00";
      Persistent = true;
    };
  };
}
