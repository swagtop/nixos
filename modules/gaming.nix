{ self, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  environment.systemPackages = [
    self.packages.${system}.discord
  ];

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    package = self.packages.${system}.steam;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    gamescopeSession.enable = true;
  };
}
