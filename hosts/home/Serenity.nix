{ config, pkgs, unstable, home-manager, ...}:

{
  # imports = [../../modules/zsh/main.nix ../../modules/zsh/zplug.nix ../../modules/git.nix ../../modules/tmux.nix ../../modules/i3/basic.nix ../../modules/picom.nix ../../modules/kitty.nix];
  # imports = [../../modules/nushell.nix ../../modules/git.nix ../../modules/tmux.nix ../../modules/i3/basic.nix ../../modules/picom.nix ../../modules/kitty.nix ../../modules/rofi.nix];

  home.stateVersion = "23.11";

  # programs.zsh.enable = true;

  # home.packages = [

  #   # General
  #   pkgs.gnupg
  #   pkgs.discord
  #   pkgs.spotify
  #   pkgs.neofetch
  #   pkgs.nerdfonts
  #   pkgs.whois
  #   pkgs.dropbox
  #   pkgs.kitty
  #   pkgs.firefox
  #   pkgs.w3m
  #   pkgs.pciutils
  #   pkgs.arandr
  #   pkgs.openvpn
  #   pkgs.htop
  #   pkgs.file
  #   pkgs.chromium
  #   pkgs.lxappearance
  #   pkgs.vim
  #   pkgs.openvpn
  #   pkgs.virt-viewer
  #   pkgs.playerctl
  #   pkgs.dig
  #   pkgs.vscode-fhs
  #   pkgs.nix-index
  #   pkgs.lutris
  #   pkgs.nordic
  #   pkgs.xwaylandvideobridge
  #   pkgs.openssl
  #   # pkgs.kdePackages.krdc
  #   pkgs.remmina
  #   pkgs.libreoffice-fresh
  #   pkgs.unzip
  #   pkgs.emacs
  #   

  #   # C/C++
  #   pkgs.cmake
  #   pkgs.gnumake
  #   pkgs.gcc

  #   # Python
  #   pkgs.jetbrains.pycharm-community

  #   # Elixir
  #   pkgs.elixir

  #   # Haskell
  #   pkgs.ghc

  #   # Rust
  #   pkgs.rustup

  #   # Containers/DevOps
  #   pkgs.distrobox
  #   pkgs.talosctl
  #   pkgs.kubectl
  #   pkgs.k9s
  #   pkgs.kubernetes-helm
  #   pkgs.skopeo
  #   pkgs.minikube
  #   pkgs.ansible

  #   # Nushell
  #   # pkgs.nushell
  #   pkgs.nushellPlugins.query

  #   # Security
  #   pkgs.nmap
  #   pkgs.gobuster
  #   unstable.seclists
  #   pkgs.netcat-openbsd
  #   pkgs.xsser
  #   pkgs.samba4Full
  #   pkgs.responder
  #   unstable.python312Packages.impacket
  #   pkgs.crackmapexec
  #   unstable.bloodhound
  #   unstable.enum4linux
  #   unstable.kerbrute


  #   # Networking
  #   pkgs.unifi


  #   # PHP
  #   pkgs.php
  # ];

 
  # programs.home-manager.enable = true;

  # gtk = {
  #   enable = true;
  #   cursorTheme = {
  #     name = "Catppuccin-Mocha-Dark-Cursors";
  #     package = pkgs.catppuccin-cursors.mochaDark;
  #   };
  #   theme = {
  #     name = "Catppuccin-Mocha-Compact-Pink-Dark";
  #     package = pkgs.catppuccin-gtk.override {
  #       accents = [ "pink" ];
  #       size = "compact";
  #       tweaks = [ "rimless" "black" ];
  #       variant = "mocha";
  #     };
  #   };
  # };

  # # home.pointerCursor = {
  # #   name = "Catppuccin-Mocha-Dark-Cursors";
  # #   package = pkgs.catppuccin-cursors.mochaDark;
  # #   size = 25;
  # # };

  # # programs.autorandr = {
  # #   enable = true;
  # #   profiles."default".config = {
  # #     "DP-0" = {
  # #       enable = true;
  # #       primary = false;
  # #       position = "2560x0";
  # #     };
  # #     "DP-4" = {
  # #       enable = true;
  # #       primary = true;
  # #       position = "0x0";
  # #     };
  # #   };
  # # };

  # fonts.fontconfig.enable = true;

}

