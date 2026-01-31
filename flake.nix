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
    inputs@{ self, hytale-flake, ... }:
    let
      nixpkgs = inputs.nixpkgs.lib.recursiveUpdate inputs.nixpkgs {
        nixpkgs = {
          config.allowUnfree = true;
        };
      };
      swagpkgs =
        system:
        let
          pkgs = (
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }
          );
        in
        import ./swagpkgs.nix {
          inherit (nixpkgs) lib;
          inherit pkgs;
        };
      mkSystem =
        config:
        nixpkgs.lib.nixosSystem (
          config
          // {
            specialArgs = {
              inherit self inputs;
              swaglib = import ./swaglib.nix;
            }
            // (config.specialArgs or { });
            modules = [
              ./modules/common.nix
              ./modules/nixos.nix
            ]
            ++ (config.modules or [ ]);
          }
        );
      eachSystem = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed f;
    in
    {
      formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      packages = eachSystem (system: swagpkgs system);

      nixosConfigurations = {
        gamebeast = mkSystem {
          modules = [
            ./hosts/gamebeast/configuration.nix

            ./modules/dev.nix
            ./modules/gaming.nix
            ./modules/gui.nix
            ./modules/music.nix
            ./modules/tui.nix

            ./modules/office.nix

            (
              { pkgs, ... }:
              {
                environment.systemPackages = [ hytale-flake.packages.${pkgs.stdenv.hostPlatform.system}.default ];
              }
            )

            # ./modules/linker.nix
            ./modules/use-cache.nix
          ];
        };
        swagtop = mkSystem {
          modules = [
            ./hosts/swagtop/configuration.nix

            ./modules/dev.nix
            ./modules/gui.nix
            ./modules/tui.nix

            ./modules/linker.nix
            ./modules/use-cache.nix
          ];
        };
        servtop = mkSystem {
          modules = [
            ./hosts/servtop/configuration.nix

            ./modules/dev.nix
            ./modules/ssh-server.nix
            ./modules/tui.nix

            ./modules/host-cache.nix
          ];
        };
        cooltop = mkSystem {
          modules = [
            ./hosts/cooltop/configuration.nix

            ./modules/gui.nix
            ./modules/dev.nix
            ./modules/tui.nix

            ./modules/linker.nix
            ./modules/use-cache.nix
          ];
        };
      };
    };
}
