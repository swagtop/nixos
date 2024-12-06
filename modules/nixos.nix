{ pkgs, ... }:

{
  system.autoUpgrade = {
    enable = true;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "09:00";
    randomizedDelaySec = "45min";
  };

  # NixOS store optimization and garbage collection.
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  }; 

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
