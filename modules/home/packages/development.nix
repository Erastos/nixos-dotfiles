{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.packages.development;
in
{
  options.netscape.packages.development = {
    enable = lib.mkEnableOption "development toolchains (C/C++, Haskell, Rust)" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # C/C++
      cmake
      gnumake
      gcc
      gdb

      # Haskell
      ghc

      # Rust
      cargo
      rustc

      # Nodejs
      yarn

      # Python with pip and pynvim
      python313Packages.pip
      python313Packages.pynvim

      # Sqlite DB Client
      sqlite

      _86box-with-roms

      hercules
      x3270
      regina
    ]
    # Language servers and linters for Neovim
    ++ lib.optionals config.programs.neovim.enable [
      lua-language-server
      gopls
      yaml-language-server
      pyright
      rust-analyzer
      typescript-language-server
      vscode-langservers-extracted
      eslint_d
    ];
  };
}
