{
  description = "the coolest flake ever.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ 
    self, 
    nixpkgs, 
    nixpkgs-unstable, 
    ... 
  }: {

    nixosConfigurations = {
      gamebeast = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [ 
          # ({ pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
          ./hosts/gamebeast/configuration.nix 
          ./modules/packages.nix
          ./modules/gnome.nix
          ./modules/bash.nix
          ./modules/nixos.nix
          ./modules/linker.nix
        ];
        specialArgs = {
          nixpkgs-unstable = import nixpkgs-unstable {
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
          ./modules/packages.nix
          ./modules/gnome.nix
          ./modules/bash.nix
          ./modules/nixos.nix
          ./modules/linker.nix
        ];
        specialArgs = {
          nixpkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };
    };
  };
}
