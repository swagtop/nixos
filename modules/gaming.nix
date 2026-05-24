{ self, pkgs, ... }:
{
  environment.systemPackages = [
    self.packages.${pkgs.stdenv.hostPlatform.system}.discord
  ];

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    package = self.packages.${pkgs.stdenv.hostPlatform.system}.steam;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    # gamescopeSession.enable = true;
  };
}
