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

  latestZfsCompatible =
    {
      config,
      pkgs,
    }:
    let
      inherit (pkgs.lib)
        assertMsg
        attrValues
        filterAttrs
        last
        match
        pipe
        sort
        tryEval
        versionOlder
        ;
    in
    pipe pkgs.linuxKernel.packages [
      (filterAttrs (
        name: kernel:
        (match "^linux_[0-9]+_[0-9]+$" name) != null
        && (tryEval kernel).success
        && !kernel.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken
      ))

      (
        kernels:
        assert assertMsg (kernels != { }) "No kernels compatible with zfs were found!";
        kernels
      )

      attrValues

      (sort (a: b: (versionOlder a.kernel.version b.kernel.version)))

      last
    ];
}
