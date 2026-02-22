{ pkgs, ... }:
{
  # Enable dynamic linking.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    alsa-lib-with-plugins
    libGL
    libICE
    libSM
    libX11
    libXcursor
    libXext
    libXi
    libxkbcommon
    libxkbfile
    libXrandr
    pkg-config
    steam-run
    udev
    vulkan-loader
    wayland
    xwayland
  ];
}
