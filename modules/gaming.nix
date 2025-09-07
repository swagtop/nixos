{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    discord
  ];

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    # gamescopeSession.enable = true;
    # localNetworkGameTransfers.openFirewall = true;
  };
}
