{
  lib,
  ...
}:
let
  inherit (lib)
    readDir
    attrNames
    filter
    pipe
    ;
in
{
  # Import each module in this directory.
  imports = pipe ./. [
    readDir
    attrNames
    (filter (file: file != "default.nix"))
    (map (file: ./${file}))
  ];
}
