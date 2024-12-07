{ pkgs, ... }:

{
  system.autoUpgrade = {
    enable = true;
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

  environment.systemPackages = with pkgs; [
    nix-search-cli
    nix-index
  ];

  # Bash aliases.
  programs.bash.shellAliases = {
    # Update.
    ud = "sudo nix flake update --flake ~/.config/flake";

    # Rebuild.
    rb = "sudo nixos-rebuild switch --flake ~/.config/flake";

    # Edit config, hardware config, and modules.
    ec = "$EDITOR ~/.config/flake/hosts/$(hostname)/configuration.nix";
    ehc = "$EDITOR ~/.config/flake/hosts/$(hostname)/hardware-configuration.nix";
    ep = "$EDITOR ~/.config/flake/modules/packages.nix";
    eb = "$EDITOR ~/.config/flake/modules/bash.nix";
    en = "$EDITOR ~/.config/flake/modules/nixos.nix";

    # Nix commands.
    ns = "nix-shell";
    ni = "nix-index";
    nl = "nix-locate";
    nd = "nix develop";
  };
}
