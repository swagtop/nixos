{
  description = "Home of my cool Nix configurations.";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hytale-flake = {
      url = "github:swagtop/hytale-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      hytale-flake,
      ...
    }:
    let
      inherit (builtins)
        foldl'
        mapAttrs
        ;

      swaglib = import ./lib.nix;

      inherit (swaglib)
        importDirectory
        ;

      perSystem =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          packages = import ./packages pkgs;
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
                    inherit self swaglib inputs;
                  };

                  modules = host.modules or [ ] ++ [
                    ./hosts/${name}/configuration.nix
                    (importDirectory { dir = ./modules/core; })
                  ];
                }
              )
            );

            hytaleModule =
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

                hytaleModule
              ];
            };
            swagtop = {
              modules = [
                ./modules/dev.nix
                ./modules/gui.nix
              ];
            };
            servtop = {
              modules = [
                ./modules/dev.nix
              ];
            };
            cooltop = {
              modules = [
                ./modules/dev.nix
                ./modules/gui.nix
              ];
            };
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
