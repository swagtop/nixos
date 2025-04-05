{
  description = "My cool system flake!";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, nixpkgs-unstable, ... }: 
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations = {
      gamebeast = lib.nixosSystem {
        specialArgs = { inherit system unstable; };
        modules = [ 
          ./hosts/gamebeast/configuration.nix 
          ./hosts/gamebeast/hardware-configuration.nix 
          ./modules/nixos.nix
          # ./modules/linker.nix

          ./modules/packages.nix

          ./modules/gnome.nix
          ./modules/music.nix
          ./modules/dev.nix
          ./modules/tui.nix
        ];
      };
      swagtop = lib.nixosSystem {
        specialArgs = { inherit system unstable; };
        modules = [ 
          ./hosts/swagtop/configuration.nix 
          ./modules/nixos.nix
          ./modules/linker.nix

          ./modules/packages.nix

          ./modules/gnome.nix
          ./modules/dev.nix
          ./modules/tui.nix
        ];
      };
      servtop = lib.nixosSystem {
        specialArgs = { inherit system unstable; };
        modules = [ 
          ./hosts/servtop/configuration.nix 
          ./modules/nixos.nix

          ./modules/packages.nix

          ./modules/dev.nix
          ./modules/tui.nix
        ];
      };
    };
  };
}
