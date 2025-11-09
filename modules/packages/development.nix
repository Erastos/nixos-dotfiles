{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.packages.development;
in
{
  options.netscape.packages.development = {
    enable = lib.mkEnableOption "development toolchains (C/C++, Haskell, Rust)" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.netscape = {
      home.packages = with pkgs; [
        # C/C++
        cmake
        gnumake
        gcc

        # Haskell
        ghc

        # Rust
        rustup
      ];
    };
  };
}
