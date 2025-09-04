{ pkgs, lib, ... }:
{
  environment.systemPackages =
  let
    mkDiscord = string: 
      (pkgs.writeShellScriptBin "${string}" ''
        exec ${pkgs.discord}/bin/"${string}" \
          --ignore-gpu-blocklist \
          --disable-features=UseOzonePlatform \
          --enable-features=VaapiVideoDecoder \
          --use-gl=desktop \
          --enable-gpu-rasterization \
          --enable-zero-copy \
          "$@"
      '');
  in [
    (mkDiscord "discord")
    (mkDiscord "Discord")
    pkgs.discord
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
