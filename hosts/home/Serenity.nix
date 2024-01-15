{ config, pkgs, unstable, home-manager, ...}:

{
  imports = [../../modules/zsh/main.nix ../../modules/zsh/prezto.nix ../../modules/git.nix ../../modules/tmux.nix];

  home.stateVersion = "23.11";

  programs.zsh.enable = true;


  home.packages = [
    pkgs.gnupg
    pkgs.dropbox
    # pkgs.discord
    unstable.discord
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
    pkgs.kitty
    pkgs.firefox
    pkgs.w3m
    pkgs.pciutils
    pkgs.arandr
    pkgs.openvpn
    # pkgs.dropbox-cli
    pkgs.htop
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

  # programs.autorandr = {
  #   enable = true;
  #   profiles."default".config = {
  #     "DP-0" = {
  #       enable = true;
  #       primary = false;
  #       position = "2560x0";
  #     };
  #     "DP-4" = {
  #       enable = true;
  #       primary = true;
  #       position = "0x0";
  #     };
  #   };
  # };

  fonts.fontconfig.enable = true;


  home.sessionVariables = {

  };

}
