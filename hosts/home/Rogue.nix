{ config, pkgs, home-manager, ...}:

{
  imports = [../../modules/zsh/main.nix ../../modules/zsh/prezto.nix ../../modules/git.nix ];

  home.stateVersion = "23.11";

  programs.zsh.enable = true;

  home.packages = [
    pkgs.gnupg
    pkgs.dropbox
    pkgs.discord
    pkgs.spotify
    pkgs.neofetch
    pkgs.nerdfonts
    pkgs.netcat
    pkgs.whois
    pkgs.cmake
    pkgs.gnumake
    pkgs.gcc
    pkgs.elixir
    pkgs.ghc
    pkgs.rustup
  ];


  programs.home-manager.enable = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Numix Square";
      package = pkgs.numix-icon-theme-square;
    };
    theme = {
      name = "Catppuccin-Macchiato-Compact-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" "black" ];
        variant = "mocha";
      };
    };
  };

  home.pointerCursor = {
    name = "Catppuccin-Macchiato-Dark-Cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 25;
  };

  fonts.fontconfig.enable = true;
  
}
