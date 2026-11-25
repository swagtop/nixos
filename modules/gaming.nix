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
    package = swagpkgs.steam;
    extraCompatPackages =
      let
        wayland-steam = pkgs.steam.overrideAttrs (safeOverride {
          nativeBuildInputs = [ pkgs.makeWrapper ];
          buildCommand = ''
            wrapProgram $out/bin/steam \
              --add-flags "steam://unlockh264" \
              --set PROTON_USE_WAYLAND 1
          '';
        });
      in
      [ wayland-steam ];
    extest.enable = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}
