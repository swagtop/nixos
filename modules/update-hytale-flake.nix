{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) getExe;

  script = pkgs.writeShellScriptApplication {
    name = "update-hytale-flake";
    runtimeInputs = with pkgs; [
      curl
      gh
      git
      jq
    ];
    text = ''
      git clone https://github.com/swagtop/hytale-flake
      cd hytale-flake
      ./update-hashes
      git add hashes.nix
      git commit -m "Update to $(cat .version)"
      git push
    '';
  };
in
{
  services.systemd.update-hytale-flake = {
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
      PrivaTmp = true;
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
