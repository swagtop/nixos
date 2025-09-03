{ lib, pkgs, ... }:
let
  bitwig-with-libs =
  let
    newest-bitwig-studio = 
      pkgs.bitwig-studio.override (old: {
        bitwig-studio-unwrapped = old.bitwig-studio-unwrapped.overrideAttrs rec {
          version = "5.3.13";
          src = pkgs.fetchurl {
            name = "bitwig-studio-${version}.deb";
            url = "https://www.bitwig.com/dl/Bitwig%20Studio/${version}/installer_linux/";
            hash = "sha256-tx+Dz9fTm4DIobwLa055ZOCMG+tU7vQl11NFnEKMAno=";
          };
        };
      });
    bitwig-wrapper = 
      pkgs.writeShellScriptBin "bitwig-studio" ''
        export LD_LIBRARY_PATH="${
          lib.makeLibraryPath (with pkgs; [
            alsa-lib
            alsa-utils
            curlWithGnuTls
            fontconfig
            freetype
            libGL
            libsecret.out
            libsndfile
            libudev0-shim
            pkg-config
            udev
            bitwig-studio
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
        export VST3_PATH="${pkgs.vital}/lib/vst3"
        exec ${newest-bitwig-studio}/bin/bitwig-studio "$@"
      '';
  in
    pkgs.symlinkJoin {
      inherit (pkgs.bitwig-studio) version;
      name = "bitwig-with-libs";
      pname = "bitwig-studio";
      ignoreCollisions = true;
      paths = [
        bitwig-wrapper
        newest-bitwig-studio
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
    vital
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
