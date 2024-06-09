{ config, pkgs, unstable, home-manager, ...}:

{
  # imports = [../../modules/zsh/main.nix ../../modules/zsh/zplug.nix ../../modules/git.nix ../../modules/tmux.nix ../../modules/i3/basic.nix ../../modules/picom.nix ../../modules/kitty.nix];
  imports = [../../modules/nushell.nix ../../modules/git.nix ../../modules/tmux.nix ../../modules/i3/basic.nix ../../modules/picom.nix ../../modules/kitty.nix ../../modules/rofi.nix];

  home.stateVersion = "23.11";

  programs.zsh.enable = true;

  home.packages = [
    pkgs.gnupg
    # pkgs.dropbox
    # pkgs.discord
    unstable.discord
    pkgs.spotify
    pkgs.neofetch
    pkgs.nerdfonts
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
    pkgs.dropbox
    pkgs.htop
    pkgs.file
    pkgs.chromium
    pkgs.distrobox
    pkgs.lxappearance
    pkgs.jetbrains.pycharm-community
    pkgs.playerctl
    pkgs.nushell
    pkgs.nushellPlugins.query
    pkgs.openvpn
    pkgs.virt-viewer
    pkgs.dig

    pkgs.vim

    pkgs.vscode-fhs

    pkgs.talosctl
    pkgs.kubectl
    pkgs.k9s
    pkgs.kubernetes-helm
    pkgs.skopeo
    pkgs.minikube


    # Security
    pkgs.nmap
    pkgs.gobuster
    unstable.seclists
    pkgs.netcat-openbsd
    unstable.xsser
  ];

 
  programs.home-manager.enable = true;

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
    };
    theme = {
      name = "Catppuccin-Mocha-Compact-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" "black" ];
        variant = "mocha";
      };
    };
 };

  # home.pointerCursor = {
  #   name = "Catppuccin-Mocha-Dark-Cursors";
  #   package = pkgs.catppuccin-cursors.mochaDark;
  #   size = 25;
  # };

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

}

