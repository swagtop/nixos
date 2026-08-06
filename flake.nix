{
  description = "Home of my configuration files.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
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
      inherit (nixpkgs.lib)
        attrNames
        foldl'
        listToAttrs
        mapAttrs
        readDir
        removeSuffix
        ;

      swaglib = import ./lib.nix;

      inherit (swaglib)
        importDirectory
        ;

      patches = listToAttrs (
        let
          filenames = attrNames (readDir ./patches);
        in
        map (name: {
          name = removeSuffix ".patch" name;
          value = ./patches/${name};
        }) filenames
      );

      perSystem =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          packages = import ./packages (pkgs // { inherit patches; });
          formatter = pkgs.nixfmt-tree;
        };

      flake = {
        nixosConfigurations =
          let
            mapHosts = mapAttrs (
              name: host:
              nixpkgs.lib.nixosSystem (
                host
                // {
                  specialArgs = host.specialArgs or { } // {
                    inherit
                      inputs
                      patches
                      self
                      swaglib
                      ;
                  };

                  modules = host.modules or [ ] ++ [
                    ./hosts/${name}/configuration.nix
                    (importDirectory { dir = ./modules/core; })
                  ];
                }
              )
            );

            hytale-module =
              { pkgs, ... }:
              let
                hostSystem = pkgs.stdenv.hostPlatform.system;
              in
              {
                environment.systemPackages = [
                  hytale-flake.packages.${hostSystem}.default
                ];
              };

          in
          mapHosts {
            gamebeast = {
              modules = [
                ./modules/dev.nix
                ./modules/gaming.nix
                ./modules/gui.nix
                ./modules/music.nix

                ./modules/office.nix

                hytale-module
              ];
            };
            servtop = {
              modules = [
                ./modules/dev.nix
              ];
            };
            duster = {
              modules = [
                ./modules/dev.nix
                ./modules/gui.nix
                lanzaboote.nixosModules.lanzaboote
              ];
            };
            files = { };
            builder = { };
          };
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
