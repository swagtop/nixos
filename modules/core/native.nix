{
  pkgs,
  config,
  lib,
  swaglib,
  inputs,
  ...
}:
let
  cfg = config.swag.native;

  optimizeForNative = swaglib.optimizeForNative pkgs cfg.march;
in
{
  # Run 'gcc -march=native -Q --help=target | grep march' to get march.
  options.swag.native.march = lib.mkOption {
    type = lib.types.str;
    default = null;
  };

  config._module.args.pkgsNative =
    let
      nuPkgs = import inputs.nixpkgs {
        inherit (pkgs.stdenv.hostPlatform) system;
        allowUnfree = true;
      };
    in
    if cfg.march == null then
      pkgs
    else
      lib.mapAttrs (
        name: value: if lib.isDerivation value then optimizeForNative value else value
      ) nuPkgs;
}
