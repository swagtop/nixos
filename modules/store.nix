{ ... }:
{
  nix.settings = {
    substituters = [
      "https://cache.spirre.vip"
    ];
    trusted-public-keys = [
      "cache.spirre.vip:jnYuXaQxsp5/9SWHeeCzVYVmYs6xXgl5/5LXnDJ+WbU="
    ];
  };
}
