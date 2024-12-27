{ lib, unstable, pkgs, ... }:
let
  bitwig-fhs = pkgs.buildFHSUserEnv {
    name = "bitwig-fhs-env";
    targetPkgs = pkgs: with pkgs; [
      # Add any other dependencies that might be required
      unstable.bitwig-studio
      alsa-utils
      alsa-lib
      libsndfile
      udev
      libudev0-shim
      vulkan-loader
      pkg-config
      xorg.libX11
      xorg.libXrandr
      xorg.libXcursor
      xorg.libXi
      xorg.libSM
      xorg.libICE
      xorg.libXext
      libGL
      libstdcxx5
      freetype
      wayland
      xwayland
      wayland-protocols
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
    wineWow64Packages.full
    libsndfile
    # unstable.vital
    desktop-file-utils
  ];

  # Add a .desktop entry for Bitwig Studio
  environment.etc."xdg/autostart/bitwig.desktop".text = ''
    [Desktop Entry]
    Name=Bitwig Studio
    Comment=Music Production Software
    Exec=${pkgs.writeShellScriptBin "bitwig-fhs" "${bitwig-fhs}/bin/bitwig-fhs-env"}
    Icon=${unstable.bitwig-studio}/share/icons/hicolor/512x512/apps/bitwig.png
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
