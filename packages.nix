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
    pkgs.symlinkJoin {
      name = "${package.name}-thru-overlay";
      paths = [ package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${execName} ${builtins.concatStringsSep " " args};
      '';
      passthru.meta.mainProgram = execName;
    };

  helix =
    let
      configFile = pkgs.stdenvNoCC.mkDerivation {
        name = "helix-config";
        src = ./configs/helix/config.toml;
        phases = [ "installPhase" ];

        # Make sure config is pointing to theme in store.
        installPhase = ''
          cp $src $out
          substituteInPlace $out --replace "cool-theme" "${./configs/helix/themes}/cool-theme"
        '';
      };
    in
    symlinkWrap {
      package = pkgs.helix.override (old: {
        helix-unwrapped = old.helix-unwrapped.overrideAttrs (oldAttrs: {
          patches = oldAttrs.patches or [ ] ++ [ ./patches/helix-upppercase-commands.patch ];
        });
      });
      execName = "hx";
      args = [
        "--add-flags \"--config ${configFile}\""
      ];
    };

  zellij = symlinkWrap {
    package = pkgs.zellij;
    execName = "zellij";
    args = [
      "--add-flags \"-c ${./configs/zellij/config.kdl}\""
    ];
  };
in
{
  inherit helix zellij;

  install-system = import ./install-system.nix { inherit pkgs; };

  # Music production things.
  bitwig-studio =
    let
      version = "5.3.13";
      bitwig-studio-at-version = pkgs.bitwig-studio5;
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
              bitwig-studio
              curlWithGnuTls
              fontconfig
              freetype
              libGL
              libICE
              libsecret.out
              libSM
              libsndfile
              libudev0-shim
              libX11
              libXcursor
              libXext
              libXi
              libXrandr
              pkg-config
              udev
              vulkan-loader
              wayland
              wayland-protocols
              # wineWowPackages.yabridge
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
          "--enable-features=UseOzonePlatform"
          "--ozone-platform=wayland"
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

  alacritty = symlinkWrap {
    package = pkgs.alacritty;
    execName = "alacritty";
    args = [
      "--add-flags \"--config-file ${./configs/alacritty/alacritty.toml}\""
    ];
  };

  locd =
    let
      package =
        {
          alsa-lib,
          fetchurl,
          fontconfig,
          freetype,
          lib,
          libgcc,
          stdenvNoCC,
          unzip,

          installStandalone ? true,
        }:
        stdenvNoCC.mkDerivation (finalAttrs: {
          pname = "locd";
          version = "1.0.5";
          src = fetchurl {
            url = "https://api.crql.works/download/locd/linux/${finalAttrs.version}";
            sha256 = "sha256-nO4LRZTgd9gEordswjeI3C4u2Lfv/xl4Cpaq0+in/MY=";

            # Will not fetch zipfile properly unless setting user agent.
            curlOpts = "-A Mozilla/5.0";
          };
          nativeBuildInputs = [ unzip ];
          buildInputs = [
            alsa-lib
            fontconfig
            freetype
            libgcc
          ];
          unpackPhase = ''
            unzip $src
          '';

          installPhase = ''
            mkdir -p $out/lib
            cp -r CLAP $out/lib/clap
            cp -r VST3 $out/lib/vst3
          ''
          + lib.optionalString installStandalone ''
            mkdir -p $out/bin
            cp -r Standalone/* $out/bin/
          '';

          meta = {
            license = lib.licenses.unfreeRedistributable;
          }
          // lib.optionalAttrs installStandalone {
            mainProgram = "LOCD";
          };
        });
    in
    pkgs.callPackage package { };

  ide = pkgs.writeShellApplication {
    name = "ide";
    runtimeInputs = [
      helix
    ];
    text = ''
      exec ${zellij}/bin/zellij "$@"
    '';
  };
}
