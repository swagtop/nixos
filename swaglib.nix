{
  # Run 'gcc -march=native -Q --help=target | grep march' to get march.
  optimizeForNative =
    pkgs: march: pkg:
    let
      nativeStdenv =
        pkgs.stdenvAdapters.withCFlags
          [ "-march=${march}" "-mtune=${march}" ]
          pkgs.stdenv;
      pkg' = pkg.override { stdenv = nativeStdenv; };
    in
      pkg'.overrideAttrs (oldAttrs: {
        env = (oldAttrs.env or {}) // {
          RUSTFLAGS = (oldAttrs.RUSTFLAGS or "") + " -C target-cpu=${march}";
        };
      });
 }
