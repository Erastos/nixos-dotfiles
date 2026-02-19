{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.packages.development;
in
{
  options.netscape.packages.development = {
    enable = lib.mkEnableOption "development toolchains (C/C++, Haskell, Rust)" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.netscape = { config, ... }: {
      home.packages = with pkgs; [
        # C/C++
        cmake
        gnumake
        gcc

        # Haskell
        ghc

        # Rust
        cargo
        rustc

        # Python with pip and pynvim
        python313Packages.pip
        python313Packages.pynvim

        # Fast file finder for telescope
        fd

        # Sqlite DB Client 
        sqlite

        _86Box-with-roms

      ]
      # LSP servers for Neovim
      ++ lib.optionals config.programs.neovim.enable [
        lua-language-server
        gopls
        yaml-language-server
        pyright
        rust-analyzer
      ];
    };
  };
}
