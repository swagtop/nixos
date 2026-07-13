{
  description = "My cool system flake!";
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

      perSystem =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          packages = import ./packages.nix pkgs;
          formatter = pkgs.nixfmt-tree;
        };

      flake.nixosConfigurations =
        let
          mapHosts = mapAttrs (
            name: host:
            nixpkgs.lib.nixosSystem (
              host
              // {
                specialArgs = host.specialArgs or { } // {
                  inherit self inputs;
                  swaglib = import ./lib.nix;
                };

                modules = host.modules or [ ] ++ [
                  ./hosts/${name}/configuration.nix
                  ./modules/cache.nix
                  ./modules/common.nix
                  ./modules/nixos.nix
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
              ./modules/tui.nix

              ./modules/office.nix

              hytaleModule
            ];
          };
          swagtop = {
            modules = [
              ./modules/dev.nix
              ./modules/gui.nix
              ./modules/tui.nix

              ./modules/linker.nix
            ];
          };
          servtop = {
            modules = [
              ./modules/dev.nix
              ./modules/ssh-server.nix
              ./modules/tui.nix
            ];
          };
          cooltop = {
            modules = [
              ./modules/dev.nix
              ./modules/gui.nix
              ./modules/tui.nix

              ./modules/linker.nix
            ];
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
