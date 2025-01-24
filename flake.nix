{
  description = "the coolest flake ever.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { 
    nixpkgs, 
    unstable, 
    ... 
  }: {
    nixosConfigurations = {
      gamebeast = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [ 
          # ({ pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
          ./hosts/gamebeast/configuration.nix 
          ./hosts/gamebeast/hardware-configuration.nix 
          ./modules/nixos.nix
          ./modules/linker.nix

          ./modules/packages.nix

          ./modules/gnome.nix
          ./modules/music.nix
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
      swagtop = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [ 
          # ({ pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
          ./hosts/swagtop/configuration.nix 
          ./modules/nixos.nix
          ./modules/linker.nix

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
