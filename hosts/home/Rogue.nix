{ config, pkgs, home-manager, ...}:

{
  imports = [../../modules/zsh/main.nix ../../modules/zsh/prezto.nix ../../modules/git.nix ../../modules/tmux.nix ../../modules/nushell.nix];

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
    pkgs.file

    # C/C++
    pkgs.valgrind
    pkgs.cmake
    pkgs.gnumake
    pkgs.gcc
    pkgs.boost
    pkgs.stdman

    # Haskell
    pkgs.ghc

    # Rust
    pkgs.rustup

    # Elixir
    pkgs.elixir

    # Python
    pkgs.python311
    pkgs.python311Packages.networkx
    pkgs.python311Packages.numpy 

    # Containers
    pkgs.skopeo
    pkgs.distrobox

    # Emacs
    pkgs.emacs
    pkgs.ripgrep

    # Security
    pkgs.radare2

    # DevOps
    pkgs.jq

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
