{
  pkgs,
  swagpkgs,
  ...
}:
{
  environment.systemPackages = [
    swagpkgs.discord
  ];

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    package = swagpkgs.steam;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    gamescopeSession.enable = true;
  };
}
