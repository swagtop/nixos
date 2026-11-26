{
  pkgs,
  swagpkgs,
  swaglib,
  ...
}:
let
  inherit (swaglib) safeOverride;
in
{
  environment.systemPackages = [
    swagpkgs.discord
  ];

  programs.steam = {
    enable = true;
    package = pkgs.steam.overrideAttrs (safeOverride {
      nativeBuildInputs = [ pkgs.makeWrapper ];
      buildCommand = ''
        wrapProgram $out/bin/steam \
          --add-flags "steam://unlockh264" \
          --set PROTON_USE_WAYLAND 1
      '';
    });
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    extest.enable = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}
