{ ... }:
{
  nixosModuleLib.devPkgs = { lib, pkgs, ... }:
  {
    home-manager.users.netscape = { config, ... }: {
      home.packages = with pkgs; [
        cmake
        gnumake
        gcc
        ghc
        cargo
        rustc
        python313Packages.pip
        python313Packages.pynvim
        fd
        sqlite
        _86Box-with-roms
        hercules
      ]
      ++ lib.optionals config.programs.neovim.enable [
        lua-language-server
        gopls
        yaml-language-server
        pyright
        rust-analyzer
        ansible-language-server
      ];
    };
  };
}
