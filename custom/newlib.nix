let
  pkgs = import <nixpkgs> {} ;
  newlib' = pkgsCross.i686-embedded.newlib.overrideAttrs ({
    nativeBuildInputs = with pkgs; [ breakpointHook less ];
    depsBuildBuild = [ buildPackages.gcc13 texinfo ];
    });
in
newlib'.override ({
  stdenv = pkgs.gcc13Stdenv;
})

