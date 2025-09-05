{
  description = "My cool system flake!";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, ... }: 
  let
    nixpkgs =
      inputs.nixpkgs.lib.recursiveUpdate
        inputs.nixpkgs { nixpkgs.config.allowUnfree = true; };
    mkSystem = config: nixpkgs.lib.nixosSystem
      (nixpkgs.lib.recursiveUpdate { specialArgs = { inherit self; }; } config);
  in
  {
    nixosConfigurations = {
      gamebeast = mkSystem {
        modules = [ 
          ./hosts/gamebeast/configuration.nix 
          ./modules/common.nix
          ./modules/nixos.nix

          ./modules/dev.nix
          ./modules/gaming.nix
          ./modules/gui.nix
          ./modules/music.nix
          ./modules/tui.nix

          ./modules/linker.nix
        ];
      };
      swagtop = mkSystem {
        modules = [ 
          ./hosts/swagtop/configuration.nix 
          ./modules/common.nix
          ./modules/nixos.nix

          ./modules/dev.nix
          ./modules/gui.nix
          ./modules/tui.nix

          ./modules/linker.nix
        ];
      };
      servtop = mkSystem {
        modules = [ 
          ./hosts/servtop/configuration.nix 
          ./modules/common.nix
          ./modules/nixos.nix

          ./modules/dev.nix
          ./modules/ssh-server.nix
          ./modules/tui.nix
        ];
      };
    };
  };
}
