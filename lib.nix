let
  getNixFiles =
    {
      dir,
      excludeDefault ? false,
    }:
    let
      inherit (builtins)
        foldl'
        readDir
        attrNames
        filter
        substring
        stringLength
        ;

      pipe = foldl' (acc: f: f acc);

      checkFile =
        filename:
        let
          nameLength = stringLength filename;
          lastThreeChars = substring (nameLength - 4) nameLength filename;
          isNotDefault = filename != "default.nix";
        in
        lastThreeChars == ".nix" && (if excludeDefault then isNotDefault else true);

    in
    pipe dir ([
      readDir
      attrNames
      (filter (checkFile))
      (map (name: "${dir}/${name}"))
    ]);
in
{
  # Run 'gcc -march=native -Q --help=target | grep march' to get march.
  optimizeForNative =
    pkgs: march: pkg:
    let
      inherit (builtins)
        mapAttrs
        ;

      nativeStdenv = pkgs.stdenvAdapters.withCFlags [ "-march=${march}" "-mtune=${march}" ] pkgs.stdenv;
      pkg' = pkg.override { stdenv = nativeStdenv; };
    in
    pkg'.overrideAttrs (oldAttrs: {
      env =
        (oldAttrs.env or { })
        // mapAttrs (name: value: (oldAttrs.${name} or "") + value) {
          # For Rust programs.
          RUSTFLAGS = " -C target-cpu=${march}";

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

  importDirectory =
    {
      dir,
      excludeDefault ? false,
    }:
    {
      imports = getNixFiles { inherit dir excludeDefault; };
    };
}
