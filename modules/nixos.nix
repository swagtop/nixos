{ pkgs, ... }:

let
  shellAliases = {
    # Update.
    ud = "sudo nix flake update --flake /etc/nixos";

    # Rebuild.
    rb = "sudo nixos-rebuild switch --flake /etc/nixos";

    # 'Edit flake'. Go to /etc/nixos as root.
    ef = "/bin/sh -c 'cd /etc/nixos; sudo su'";

    # Nix commands.
    nd = "nix develop";
    ni = "nix-index";
    nl = "nix-locate";
  };

  # Shorthand for `nix shell nixpkgs#$1 nixpkgs#$2 ...`.
  promptInit = ''
    ns() {
      ORIGINAL_NAME="$name"
      local NIX_SHELL="NIXPKGS_ALLOW_UNFREE=1 nix shell --impure"
      if [[ "$@" == "" ]]; then
        return
      fi
      name='ns'
      for arg in "$@"; do
        NIX_SHELL+=" nixpkgs#$arg"
        name+="-$arg"
      done
      export name=$name && (eval "$NIX_SHELL" || export name=$ORIGINAL_NAME)
      export name=$ORIGINAL_NAME
    }
  '';
in
{
  # Set system to auto update and upgrade flake.
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos";
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "09:00";
    randomizedDelaySec = "45min";
  };

  # NixOS store optimization and garbage collection.
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      keep-derivations = true;
      keep-outputs = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  }; 

  # Useful Nix commands.
  environment = {
    systemPackages = with pkgs; [
      nix-search-cli
      nix-index
    ];
  }; 

  programs.direnv = {
    enable = true;
    package = pkgs.direnv;
    silent = true;
    nix-direnv = {
      enable = true;
      package = pkgs.nix-direnv;
    };
  };

  # Bash aliases.
  programs.bash = {
    promptInit = promptInit;
    shellAliases = shellAliases;
  };
}
