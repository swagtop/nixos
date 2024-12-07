{ pkgs, ... }:

{
  # Enable dynamic linking.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Bevy dependencies
    alsa-utils
    alsa-lib
    pkg-config
    udev
    libudev0-shim
    vulkan-loader
    xorg.libX11
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXi
    rustup
    steam-run
    stdenv.cc.cc.lib
    glibc.dev
  ];
}
