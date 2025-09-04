{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    (discord.overrideAttrs (old:
      let
        flags = "${lib.concatStringsSep " " [
          "--ignore-gpu-blocklist"
          "--disable-features=UseOzonePlatform"
          "--enable-features=VaapiVideoDecoder"
          "--use-gl=desktop"
          "--enable-gpu-rasterization"
          "--enable-zero-copy"
        ]}";
      in {
        nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.makeWrapper ];
        postInstall = old.postInstall + ''
          wrapProgram $out/bin/discord --add-flags "${flags}"
          wrapProgram $out/bin/Discord --add-flags "${flags}"
        '';
      }))
  ];

  programs.steam = {
    enable = true;
    package = 
      pkgs.steam.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.makeWrapper ];
        buildCommand = old.buildCommand + ''
          wrapProgram $out/bin/steam --add-flags "steam://unlockh264";
        '';
      });
    protontricks.enable = true;
    # gamescopeSession.enable = true;
    # localNetworkGameTransfers.openFirewall = true;
  };
}
