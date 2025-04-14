{
  description = "My cool system flake!";
  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }: 
  let
    unstable-overlay = { pkgs, ... }: {
      nixpkgs.overlays = [
        (final: prev: {
          unstable = import nixpkgs-unstable {
            inherit (prev.stdenv.hostPlatform) system;
            config.allowUnfree = true; # Optional
          };
        })
      ];
    };
  in
  {
    nixosConfigurations = {
      gamebeast = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit nixpkgs-unstable; };
        modules = [ 
          unstable-overlay
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
      swagtop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit nixpkgs-unstable; };
        modules = [ 
          unstable-overlay
          ./hosts/swagtop/configuration.nix 
          ./modules/nixos.nix
          ./modules/linker.nix

          ./modules/packages.nix

          ./modules/gnome.nix
          ./modules/dev.nix
          ./modules/tui.nix
        ];
      };
      servtop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit nixpkgs-unstable; };
        modules = [ 
          unstable-overlay
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
