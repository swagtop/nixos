{ pkgs, ... }:

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
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  }; 

  # Useful Nix commands.
  environment = {
    systemPackages = with pkgs; [
      nix-search-cli
      nix-index
    ];
  }; 

  # Bash aliases.
  programs.bash.shellAliases = {
    # Update.
    ud = "sudo nix flake update --flake /etc/nixos";

    # Rebuild.
    rb = "sudo nixos-rebuild switch --flake /etc/nixos";

    # 'Edit flake'. Go to /etc/nixos as root.
    ef = "/bin/sh -c 'cd /etc/nixos; su'";

    # Nix commands.
    ns = "nix-shell";
    ni = "nix-index";
    nl = "nix-locate";
    nd = "nix develop";
  };
}
