{
  description = "the coolest flake ever.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # nix-ld.url = "github:nix-community/nix-ld";
    # nix-ld.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { 
    nixpkgs, 
    unstable, 
    # nix-ld,
    ... 
  }: {

    nixosConfigurations = {
      gamebeast = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [ 
          # ({ pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
          # nix-ld.nixosModules.nix-ld
          ./hosts/gamebeast/configuration.nix 
          ./modules/nixos.nix
          ./modules/linker.nix

          ./modules/packages.nix

          ./modules/gnome.nix
          ./modules/music.nix
          ./modules/dev.nix
          ./modules/tui.nix
          # { programs.nix-ld.dev.enable = true; }
        ];
        specialArgs = {
          unstable = import unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };
      swagtop = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [ 
          # ({ pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
          ./hosts/swagtop/configuration.nix 
          ./modules/nixos.nix
          # ./modules/linker.nix

          ./modules/packages.nix

          ./modules/gnome.nix
          ./modules/dev.nix
          ./modules/tui.nix
        ];
        specialArgs = {
          unstable = import unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };
    };
  };
}
