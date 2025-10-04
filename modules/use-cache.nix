{ lib, ... }:
{
  nix.settings = {
    substituters = lib.mkForce [
      "https://cache.spirre.vip?priority=1"
      "https://cache.nixos.org?priority=2"
    ];
    trusted-public-keys = [
      "cache.spirre.vip:jnYuXaQxsp5/9SWHeeCzVYVmYs6xXgl5/5LXnDJ+WbU="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
}
