{ pkgs, ... }:
{
  # Enable dynamic linking.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Bevy dependencies
    alsa-utils
    alsa-lib
    libsndfile
    pkg-config
    udev
    libudev0-shim
    vulkan-loader
    xorg.libX11
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXi
    xorg.libSM
    xorg.libICE
    xorg.libXext
    libGL
    freetype
    libstdcxx5
    rustup
    steam-run
    stdenv.cc.cc.lib
    glibc.dev
  ];
}
