let
  pkgs = import <nixpkgs> { };
  binutils-unwrapped' = pkgs.binutils-unwrapped.overrideAttributes(old: {
    name = "binutils-"
  })
in 
binutils'
