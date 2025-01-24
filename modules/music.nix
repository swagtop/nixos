{ lib, unstable, pkgs, ... }:
let
  bitwig-fhs = pkgs.buildFHSUserEnv {
    name = "bitwig-fhs-env";
    targetPkgs = pkgs: with pkgs; [
      # Depencencies that loaded plugins may need.
      alsa-lib
      alsa-utils
      fontconfig
      freetype
      libGL
      libsndfile
      libstdcxx5
      libudev0-shim
      pkg-config
      udev
      unstable.bitwig-studio
      vulkan-loader
      wayland
      wayland-protocols
      xorg.libICE
      xorg.libSM
      xorg.libX11
      xorg.libXcursor
      xorg.libXext
      xorg.libXi
      xorg.libXrandr
      xwayland
      zlib
    ];
    runScript = "${unstable.bitwig-studio}/bin/bitwig-studio";
  };
in
{
  environment.systemPackages = with pkgs; [
    nix-ld
    # Music stuff.
    bitwig-fhs
    yabridge
    yabridgectl
    wineWow64Packages.base
    libsndfile
    # unstable.vital
    desktop-file-utils
  ];

  # Add a .desktop entry for Bitwig Studio
  environment.etc."xdg/autostart/bitwig.desktop".text = ''
    [Desktop Entry]
    Name=Bitwig Studio
    Comment=Music Production Software
    Exec="${bitwig-fhs}/bin/bitwig-fhs-env"}
    Icon=${unstable.bitwig-studio}/share/icons/hicolor/128x128/apps/com.bitwig.BitwigStudio.png
    Terminal=false
    Type=Application
    Categories=AudioVideo;Audio;Music;Multimedia;
  '';

  security.rtkit.enable = lib.mkForce false;
  systemd.services.rtkit = {
    enable = false;
    unitConfig = {
      RefuseManualStart = true;
      RefuseManualStop = true;
    };
    # unitOverrides = ''
    #   [Unit]
    #   ConditionPathExists=!/dev/null
    # '';
  };

  security.pam.loginLimits = [
    { 
      domain = "@audio"; 
      item = "memlock"; 
      type = "-"; 
      value = "unlimited"; 
    }
    { 
      domain = "@audio"; 
      item = "rtprio"; 
      type = "-"   ; 
      value = "99"; 
    }
    { 
      domain = "@audio"; 
      item = "nofile"; 
      type = "soft"; 
      value = "99999"; 
    }
    { 
      domain = "@audio"; 
      item = "nofile"; 
      type = "hard"; 
      value = "99999"; 
    }
  ];

  services.udev.extraRules = ''
    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"
  '';
}
