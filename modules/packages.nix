{ pkgs, ... }: 

{
  # Global packages.
  environment.systemPackages = with pkgs; [
    # Zipping.
    zip
    unzip

    # Etc.
    keyd
    wget
    flatpak
    wayland
    xwayland
    wayland-protocols
    linux-firmware
  ];

}
