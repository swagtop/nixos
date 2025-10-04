{ ... }:
{
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/lib/nixos/cache-priv-key.pem";
  };

  nix.settings = {
    secret-key-files = [ "/var/lib/nixos/cache-priv-key.pem" ];
  };

  system.autoUpgrade = {
    enable = true;
    upgrade = true;
    flake = "/etc/nixos";
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
      "--commit-lock-file"
    ];
    dates = "09:00";
    randomizedDelaySec = "45min";
  };
}
