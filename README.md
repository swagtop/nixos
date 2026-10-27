# Home of my configuration files

This is where I keep all of my important personal configurations, including my
dotfiles, Nix packages, and NixOS configurations. These things are organized
into their own subdirectories, and can be found where you expect them to.


## Features

### Nix Cache

My home server automatically updates the flake inputs, and builds all of my
systems, once a day. I don't have to worry about long rebuilds from my custom
packages, or overrides, as everything is built and updated for me automatically.


## Installation

To install an existing, non-flake `/etc/nixos` configuration into the structure
of this flake, one can run:

```sh
nix run github:swagtop/nixos#install --extra-experimental-features 'nix-command flakes'
```

This script exists mostly for my own usage, to quickly enroll any new computers
or virtual machines into my setup.
