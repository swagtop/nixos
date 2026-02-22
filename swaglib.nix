{
  # Run 'gcc -march=native -Q --help=target | grep march' to get march.
  optimizeForNative =
    pkgs: march: pkg:
    let
      nativeStdenv = pkgs.stdenvAdapters.withCFlags [ "-march=${march}" "-mtune=${march}" ] pkgs.stdenv;
      pkg' = pkg.override { stdenv = nativeStdenv; };
    in
    pkg'.overrideAttrs (oldAttrs: {
      env = (oldAttrs.env or { }) // {
        # For Rust programs.
        RUSTFLAGS = (oldAttrs.RUSTFLAGS or "") + " -C target-cpu=${march}";

        # For the Linux kernel.
        KCPPFLAGS = "-march=${march} -mtune=${march} -O2";
        KCFLAGS = "-march=${march} -mtune=${march} -O2";
      };
    });
}
