{ pkgs, ... }:
{
   # Enable dynamic linking.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Bevy dependencies
    alsa-lib
    alsa-utils
    freetype
    unstable.glibc.dev
    unstable.gcc14
    libGL
    libsndfile
    # libstdcxx5
    libudev0-shim
    libudev-zero
    libxkbcommon
    pkg-config
    unstable.stdenv.cc.cc.lib
    steam-run
    udev
    vulkan-loader
    wayland
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXi
    xorg.libxkbfile
    xorg.libXrandr
    xwayland
  ];
}
