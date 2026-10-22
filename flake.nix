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

      swaglib = import ./lib.nix;

      inherit (swaglib)
        importDirectory
        ;

      patches = mapAttrs' (name: value: {
        name = removeSuffix ".patch" name;
        value = path {
          inherit name;
          path = ./patches/${name};
        };
      }) (readDir ./patches);

      perSystem =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          packages = import ./packages (pkgs // { inherit patches swaglib; });
          formatter = pkgs.nixfmt-tree;
        };

      flake.nixosConfigurations =
        let
          makeHosts = mapAttrs (
            name: host:
            nixpkgs.lib.nixosSystem (
              host
              // {
                modules = host.modules or [ ] ++ [
                  ./hosts/${name}/configuration.nix
                  (importDirectory { dir = ./modules/core; })
                  {
                    config._module.args = {
                      inherit
                        inputs
                        patches
                        self
                        swaglib
                        ;
                    };
                  }
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
          builder = { };
        };
    in
    foldl' (
      acc: system:
      let
        mergeSystem = name: value: acc.${name} or { } // { ${system} = value; };
      in
      acc // mapAttrs mergeSystem (perSystem system)
    ) flake nixpkgs.lib.systems.flakeExposed;
}
