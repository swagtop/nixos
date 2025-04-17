{
  description = "My cool system flake!";
  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs = { nixpkgs, nixpkgs-unstable, ... }: 
  let
    unstable-overlay.nixpkgs.overlays = [
      (final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (final) system config;
        };
      })
    ];
  in
  {
    nixosConfigurations = {
      gamebeast = nixpkgs.lib.nixosSystem {
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
