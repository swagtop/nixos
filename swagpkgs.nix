{
  pkgs,
  lib,
  ...
}:
let
  symlinkWrap =
    {
      package,
      execName,
      args,
    }:
    (pkgs.symlinkJoin {
      name = "${package.name}-thru-overlay";
      paths = [ package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${execName} ${builtins.concatStringsSep " " args};
      '';
    })
    // {
      meta.mainProgram = execName;
    };
in
{
  # Music production things.
  bitwig-studio =
    let
      version = "5.3.13";
      bitwig-studio-at-version = pkgs.bitwig-studio.override (old: {
        bitwig-studio-unwrapped = old.bitwig-studio-unwrapped.overrideAttrs rec {
          inherit version;
          src = pkgs.fetchurl {
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
          lib.makeLibraryPath (
            with pkgs;
            [
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
            ]
          )
        }\""
      ];
    };

  # Gaming stuff.
  discord = (
    pkgs.discord.overrideAttrs (
      old:
      let
        flags = "${lib.concatStringsSep " " [
          "--ignore-gpu-blocklist"
          "--disable-features=UseOzonePlatform"
          "--enable-features=VaapiVideoDecoder"
          "--use-gl=desktop"
          "--enable-gpu-rasterization"
          "--enable-zero-copy"
        ]}";
      in
      {
        nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.makeWrapper ];
        postInstall = old.postInstall + ''
          wrapProgram $out/bin/discord --add-flags "${flags}"
          wrapProgram $out/bin/Discord --add-flags "${flags}"
        '';
      }
    )
  );

  steam = pkgs.steam.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.makeWrapper ];
    buildCommand = old.buildCommand + ''
      wrapProgram $out/bin/steam --add-flags "steam://unlockh264";
    '';
  });

  # Applications I want to use my own config.
  alacritty = symlinkWrap {
    package = pkgs.alacritty;
    execName = "alacritty";
    args = [
      "--add-flags \"--config-file ${./configs/alacritty/alacritty.toml}\""
    ];
  };

  helix = symlinkWrap {
    package = (
      pkgs.helix.overrideAttrs (oldAttrs: {
        patches = oldAttrs.patches ++ [ ./patches/helix-upppercase-commands.patch ];
      })
    );
    execName = "hx";
    args = [
      "--set HELIX_RUNTIME \"${./configs/helix}\""
      "--add-flags \"-c ${./configs/helix/config.toml}\""
    ];
  };

  zellij = symlinkWrap {
    package = pkgs.zellij;
    execName = "zellij";
    args = [
      "--add-flags \"-c ${./configs/zellij/config.kdl}\""
    ];
  };

  locd = pkgs.stdenvNoCC.mkDerivation (
    let
      version = "1.0.5";
      pname = "locd";
      name = "${pname}-${version}";
    in
    {
      inherit name pname version;
      src = pkgs.fetchurl {
        url = "https://api.crql.works/download/locd/linux/${version}";
        sha256 = "sha256-nO4LRZTgd9gEordswjeI3C4u2Lfv/xl4Cpaq0+in/MY=";
      };
      nativeBuildInputs = [ pkgs.unzip ];
      buildInputs = with pkgs; [
        alsa-lib
        fontconfig
        freetype
        libgcc
      ];
      unpackPhase = ''
        unzip $src
      '';
      installPhase = ''
        mkdir -p $out/{lib,bin}
        cp -r CLAP $out/lib/clap
        cp -r VST3 $out/lib/vst3
        cp -r Standalone/* $out/bin/
      '';
    }
  );
}
