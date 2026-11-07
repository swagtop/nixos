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
    package = swagpkgs.steam;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    extest.enable = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}
