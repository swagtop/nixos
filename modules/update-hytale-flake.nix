{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) getExe;

  script = pkgs.writeShellApplication {
    name = "update-hytale-flake";
    runtimeInputs = with pkgs; [
      bash
      curl
      gh
      git
      jq
      nix
    ];
    text = ''
      git clone https://github.com/swagtop/hytale-flake
      cd hytale-flake
      ./update-hashes.sh
      git add hashes.nix
      if git commit -m "Update to $(cat .version)"; then
        git push
      fi
    '';
  };
in
{
  systemd.services.update-hytale-flake = {
    description = "Automatic updates of the hytale-flake.";
    after = [
      "network.target"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "thedb";
      ExecStart = getExe script;
      RuntimeDirectory = "update-hytale-flake";
      WorkingDirectory = "/run/update-hytale-flake";
      PrivateTmp = true;
    };
  };

  systemd.timers.update-hytale-flake = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      RandomizedOffsetSec = "5m";
      OnCalendar = "hourly";
    };
  };
}
