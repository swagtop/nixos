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
    type = lib.types.nullOr lib.types.str;
    default = null;
  };

  config._module.args.pkgsNative =
    let
      nuPkgs = import inputs.nixpkgs {
        inherit (pkgs) config;
        inherit (pkgs.stdenv.hostPlatform) system;
      };
    in
    if cfg.march == null then
      pkgs
    else
      let
        recursiveOptimizeDerivations =
          set:
          lib.mapAttrs (
            name: value:
            if lib.isDerivation value then
              optimizeForNative value
            else if lib.isAttrs value then
              recursiveOptimizeDerivations value
            else
              value
          ) set;
      in
      recursiveOptimizeDerivations nuPkgs;
}
