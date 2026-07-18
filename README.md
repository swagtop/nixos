# Home of my cool Nix configurations

This is where I keep all of my personal Nix configurations, including my patched
editor, my own wrapped packages, and my NixOS configurations and modules.

All of these things are located where you would expect them, based on the
directory structure.

## Installation

To install an existing, non-flake `/etc/nixos` configuration into the structure
of this flake, one can run:

```sh
nix run github:swagtop/nixos#install --extra-experimental-features 'nix-command flakes'
```

This script exists mostly for my own usage, to quickly enroll any new computers
or virtual machines into my setup.
