# Home of my configuration files

This is where I keep all of my important personal configurations, including my
dotfiles, Nix packages, and NixOS configurations. These things are organized
into their own subdirectories, to have some sort of structure, which haven't put
too much thought into.


## Features

### Nix Cache

The coolest thing I've got going is my cache setup, which once a day updates the
flake inputs, and builds all hosts subscribed to the cache with
`swag.cache.enable = true`.

If all hosts are built successfully, the lockfile is commited and pushed,
and users of the cache automatically pull the lockfile and subsequently their
pre-built systems, through the `harmonia` cache.

I don't worry about overriding anything anymore, as the penalty (long rebuilds)
for this is paid once, by my build server, overnight, while I'm sleeping.


## Installation

To install an existing, non-flake `/etc/nixos` configuration into the structure
of this flake, one can run:

```sh
nix run github:swagtop/nixos#install --extra-experimental-features 'nix-command flakes'
```

This script exists mostly for my own usage, to quickly enroll any new computers
or virtual machines into my setup.
