{
  description = "My cool system flake!";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: 
  let
    allow-unfree = { nixpkgs.config.allowUnfree = true; };
  in
  {
    nixosConfigurations = {
      gamebeast = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [ 
          allow-unfree
          ./hosts/gamebeast/configuration.nix 
          ./hosts/gamebeast/hardware-configuration.nix 
          ./modules/nixos.nix
          ./modules/linker.nix
          ./modules/common.nix

          ./modules/gnome.nix
          ./modules/music.nix
          ./modules/dev.nix
          ./modules/tui.nix
        ];
      };
      swagtop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [ 
          allow-unfree
          ./hosts/swagtop/configuration.nix 
          ./modules/nixos.nix
          ./modules/linker.nix
          ./modules/common.nix

          ./modules/gnome.nix
          ./modules/dev.nix
          ./modules/tui.nix
        ];
      };
      servtop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [ 
          allow-unfree
          ./hosts/servtop/configuration.nix 
          ./modules/nixos.nix
          ./modules/common.nix

          ./modules/dev.nix
          ./modules/tui.nix
          ./modules/ssh-server.nix
        ];
      };
    };
  };
}
