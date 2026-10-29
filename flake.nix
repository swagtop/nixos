{
  description = "Home of my configuration files.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hytale-flake = {
      url = "github:swagtop/hytale-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      lanzaboote,
      hytale-flake,
      ...
    }:
    let
      inherit (builtins)
        foldl'
        path
        ;

      inherit (nixpkgs.lib)
        mapAttrs
        mapAttrs'
        readDir
        removeSuffix
        ;

      patches =
        let
          makePurePaths = name: value: {
            name = removeSuffix ".patch" name;
            value = path {
              inherit name;
              path = ./patches/${name};
            };
          };
        in
        mapAttrs' makePurePaths (readDir ./patches);

      swaglib = import ./lib.nix;

      perSystem =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          packages = import ./packages.nix (pkgs // { inherit patches swaglib; });
          formatter = pkgs.nixfmt-tree;
        };

      flake.nixosConfigurations =
        let
          makeHosts = mapAttrs (
            name: host:
            let
              moduleArgs = { pkgs, ... }: {
                config._module.args = {
                  inherit inputs patches swaglib;
                  swagpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
                };
              };
            in
            nixpkgs.lib.nixosSystem (
              host
              // {
                modules = host.modules or [ ] ++ [
                  ./hosts/${name}/configuration.nix
                  moduleArgs
                  (swaglib.importDirectory { dir = ./modules/core; })
                ];
              }
            )
          );
        in
        makeHosts {
          gamebeast.modules = [
            ./modules/dev.nix
            ./modules/gaming.nix
            ./modules/gui.nix
            ./modules/music.nix
            ./modules/office.nix
            hytale-flake.nixosModules.hytale-launcher
          ];
          duster.modules = [
            ./modules/dev.nix
            ./modules/gui.nix
            lanzaboote.nixosModules.lanzaboote
          ];
          files = { };
        };

      flake.lib = swaglib // { inherit patches; };
    in
    foldl' (
      acc: system:
      let
        mergeSystem = name: value: acc.${name} or { } // { ${system} = value; };
      in
      acc // mapAttrs mergeSystem (perSystem system)
    ) flake nixpkgs.lib.systems.flakeExposed;
}
