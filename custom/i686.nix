let
  pkgs = import <nixpkgs> {
    crossSystem = {
      config = "i686-elf";
    };
    overlays = [
      (self: super: {
        newlib = super.newlib.override {
          stdenv = super.overrideCC super.stdenvNoCC (
            with super.buildPackages;
            let
              libc1 = binutilsNoLibc.libc;
            in
            (wrapCCWith {
              cc = gccFun {
                # copy-pasted
                noSysDirs = true;
                majorMinorVersion = toString 13;

                reproducibleBuild = true;
                profiledCompiler = false;

                isl = if !stdenv.hostPlatform.isDarwin then isl_0_20 else null;

                withoutTargetLibc = true;
                langCC = false;
                libcCross = libc1;
                targetPackages.stdenv.cc.bintools = binutilsNoLibc;
                enableShared =
                  stdenv.targetPlatform.hasSharedLibraries

                  # temporarily disabled due to breakage;
                  # see https://github.com/NixOS/nixpkgs/pull/243249
                  && !stdenv.targetPlatform.isWindows
                  && !(stdenv.targetPlatform.useLLVM or false);
              };
              bintools = binutilsNoLibc;
              libc = libc1;
              extraPackages = [ ];
            }).overrideAttrs
              (prevAttrs: {
                meta = prevAttrs.meta // {
                  badPlatforms =
                    (prevAttrs.meta.badPlatforms or [ ])
                    ++ lib.optionals (stdenv.targetPlatform == stdenv.hostPlatform) [ stdenv.hostPlatform.system ];
                };
              })
          );
        };
      })
    ];
  };
in
pkgs.stdenv.mkDerivation {
  name = "i686";
  nativeBuildInputs = [ ];
}
