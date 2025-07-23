{ pkgs, ... }:
{
  # Enable dynamic linking.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    alsa-lib
    libGL
    libxkbcommon
    pkg-config
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
