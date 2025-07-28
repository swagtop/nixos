{ lib, pkgs, ... }:
let
  # bitwig-fhs = pkgs.buildFHSEnv {
  #   name = "bitwig-fhs-env";
  #   targetPkgs = pkgs: with pkgs; [
  #     # Depencencies that loaded plugins may need.
  #     alsa-lib
  #     alsa-utils
  #     fontconfig
  #     freetype
  #     libGL
  #     libsndfile
  #     libudev0-shim
  #     pkg-config
  #     udev
  #     unstable.bitwig-studio
  #     vulkan-loader
  #     wayland
  #     wayland-protocols
  #     xorg.libICE
  #     xorg.libSM
  #     xorg.libX11
  #     xorg.libXcursor
  #     xorg.libXext
  #     xorg.libXi
  #     xorg.libXrandr
  #     xwayland
  #     zlib
  #   ];
  #   runScript = "${pkgs.unstable.bitwig-studio}/bin/bitwig-studio";
  # };
  bitwig-with-libs =
  let
    bitwig-wrapper = 
      pkgs.writeShellScriptBin "bitwig-studio" ''
        export LD_LIBRARY_PATH="${
          lib.makeLibraryPath (with pkgs; [
            alsa-lib
            alsa-utils
            fontconfig
            freetype
            libGL
            libsndfile
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
          ])
        }"
        exec ${pkgs.unstable.bitwig-studio}/bin/bitwig-studio "$@"
      '';
  in
    pkgs.symlinkJoin {
      inherit (pkgs.bitwig-studio) version;
      name = "bitwig-with-libs";
      pname = "bitwig-studio";
      ignoreCollisions = true;
      paths = [
        bitwig-wrapper
        pkgs.bitwig-studio
      ];
    };
in {
  environment.systemPackages = with pkgs; [
    nix-ld
    # Music stuff.
    bitwig-with-libs
    wineWow64Packages.yabridge
    yabridge
    (yabridgectl.overrideAttrs {
      wine = wineWow64Packages.base;
    })
    # wineWow64Packages.base
    wineWow64Packages.base
    libsndfile
    # unstable.vital
    desktop-file-utils
  ];

  # Add a .desktop entry for Bitwig Studio
    # Icon=${pkgs.unstable.bitwig-studio}/share/icons/hicolor/scalable/apps/com.bitwig.BitwigStudio.svg
  environment.etc."xdg/applications/bitwig.desktop".text = ''
    [Desktop Entry]
    Name=Bitwig Studio
    Comment=Modern music production and performance
    GenericName=Digital Audio Workstation
    Exec=${bitwig-with-libs}/bin/bitwig-studio
    Terminal=false
    Type=Application
    Categories=AudioVideo;Music;Audio;Sequencer;Midi;Mixer;Player;Recorder
    NoDisplay=false
    Icon=com.bitwig.BitwigStudio
    MimeType=application/bitwig-clip;application/bitwig-device;application/bitwig-package;application/bitwig-preset;application/bitwig-project;application/bitwig-scene;application/bitwig-template;application/bitwig-extension;application/bitwig-remote-controls;application/bitwig-module;application/bitwig-modulator;application/vnd.bitwig.dawproject
    Keywords=daw;bitwig;audio;midi
    StartupNotify=true
    StartupWMClass=com.bitwig.BitwigStudio
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
