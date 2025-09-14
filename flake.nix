{
  description = "My cool system flake!";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, ... }: 
  let
    nixpkgs =
      inputs.nixpkgs.lib.recursiveUpdate
        inputs.nixpkgs { nixpkgs = { config.allowUnfree = true; }; };
    overlay-module = {
      nixpkgs.overlays = [ (import ./modules/overlay.nix {
        inherit self;
        inherit (nixpkgs) lib;
      }) ];
    };
    mkSystem = config: nixpkgs.lib.nixosSystem (config // {
      specialArgs = { inherit self inputs; } // (config.specialArgs or {});
      modules = [
        overlay-module
        ./modules/common.nix
        ./modules/nixos.nix
      ] ++ (config.modules or []);
    });
  in
  {
    nixosConfigurations = {
      gamebeast = mkSystem {
        modules = [ 
          ./hosts/gamebeast/configuration.nix 

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

          ./modules/dev.nix
          ./modules/gui.nix
          ./modules/tui.nix

          ./modules/linker.nix
        ];
      };
      servtop = mkSystem {
        modules = [ 
          ./hosts/servtop/configuration.nix 

          ./modules/dev.nix
          ./modules/ssh-server.nix
          ./modules/tui.nix
        ];
      };
      cooltop = mkSystem {
        modules = [ 
          ./hosts/cooltop/configuration.nix 

          ./modules/gui.nix
          ./modules/dev.nix
          ./modules/tui.nix

          ./modules/linker.nix
        ];
      };
    };
  };
}
