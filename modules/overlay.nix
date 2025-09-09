{ self, lib }:
(final: prev:
let
  symlinkWrap = { package, execName, args }: prev.symlinkJoin {
    name = "${package.name}-thru-overlay";
    paths = [ package ];
    nativeBuildInputs = [ prev.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/${execName} ${builtins.concatStringsSep " " args};
    '';
  };
in {
  # Music production things.
  bitwig-studio = 
  let
    version = "5.3.13";
    bitwig-studio-at-version = 
      prev.bitwig-studio.override (old: {
        bitwig-studio-unwrapped = old.bitwig-studio-unwrapped.overrideAttrs rec {
          inherit version;
          src = prev.fetchurl {
            name = "bitwig-studio-${version}.deb";
            url = "https://www.bitwig.com/dl/Bitwig%20Studio/${version}/installer_linux/";
            hash = "sha256-tx+Dz9fTm4DIobwLa055ZOCMG+tU7vQl11NFnEKMAno=";
          };
        };
      });
  in
    symlinkWrap {
      package = bitwig-studio-at-version;
      execName = "bitwig-studio";
      args = [
        "--set LD_LIBRARY_PATH \"${
          lib.makeLibraryPath (with prev; [
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
        }\""
      ];
    };

  # Gaming stuff.
  discord = (prev.discord.overrideAttrs (old:
    let
      flags = "${lib.concatStringsSep " " [
        "--ignore-gpu-blocklist"
        "--disable-features=UseOzonePlatform"
        "--enable-features=VaapiVideoDecoder"
        "--use-gl=desktop"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
      ]}";
    in {
      nativeBuildInputs = old.nativeBuildInputs ++ [ prev.makeWrapper ];
      postInstall = old.postInstall + ''
        wrapProgram $out/bin/discord --add-flags "${flags}"
        wrapProgram $out/bin/Discord --add-flags "${flags}"
      '';
    }));

  steam = prev.steam.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ prev.makeWrapper ];
    buildCommand = old.buildCommand + ''
      wrapProgram $out/bin/steam --add-flags "steam://unlockh264";
    '';
  });
    
  # Applications I want to use my own config.
  alacritty = symlinkWrap {
    package = prev.alacritty;
    execName = "alacritty";
    args = [
      "--add-flags \"--config-file ${self}/configs/alacritty/alacritty.toml\""
    ];
  };

  helix = symlinkWrap {
    package = prev.helix;
    execName = "hx";
    args = [
      "--set HELIX_RUNTIME \"${self}/configs/helix/\""
      "--add-flags \"-c ${self}/configs/helix/config.toml\""
    ];
  };

  zellij = symlinkWrap {
    package = prev.zellij;
    execName = "zellij";
    args = [
      "--add-flags \"-c ${self}/configs/zellij/config.kdl\""
    ];
  };
})
