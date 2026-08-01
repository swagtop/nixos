# Home of my cool Nix configurations

This is where I keep all of my important personal configurations, including my
dotfiles, Nix packages, and NixOS configurations. These things are organized
into their own subdirectories, to have some sort of structure, I haven't put too
much thought into this.


## Features

### Cache

The coolest thing I've got going is my cache setup, which once a day updates the
flake inputs, and builds all hosts subscribed to the cache with
`swag.cache.enable = true`.

If all hosts are built successfully, the lockfile is commited and pushed, and
users of the cache pull the lockfile and subsequently their pre-built systems
automatically.

With this setup I don't really have to worry about causing long rebuilds on
overrides, as my cache builds everything for me, and distributes it out to all
of my computers. My low-power laptop doesn't need to spend ages building my
patched editor, and my high-power desktop doesn't need to spend ages building
my Linux kernel with extra configuration.


## Installation

To install an existing, non-flake `/etc/nixos` configuration into the structure
of this flake, one can run:

```sh
nix run github:swagtop/nixos#install --extra-experimental-features 'nix-command flakes'
```

This script exists mostly for my own usage, to quickly enroll any new computers
or virtual machines into my setup.
