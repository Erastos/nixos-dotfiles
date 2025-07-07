{ config, pkgs, unstable, home-manager, ...}:

{

  home.stateVersion = "23.11";


  home.packages = [

    # General
    pkgs.gnupg
    pkgs.discord
    pkgs.spotify
    pkgs.fastfetch
    pkgs.whois
    pkgs.dropbox
    pkgs.wezterm
    pkgs.firefox
    pkgs.w3m
    pkgs.pciutils
    pkgs.arandr
    pkgs.openvpn
    pkgs.htop
    pkgs.file
    pkgs.chromium
    pkgs.vim
    pkgs.virt-viewer
    pkgs.playerctl
    pkgs.dig
    pkgs.vscode-fhs
    pkgs.nix-index
    pkgs.openssl
    pkgs.libreoffice-fresh
    pkgs.unzip
    pkgs.emacs
    pkgs.ripgrep

    # C/C++
    pkgs.cmake
    pkgs.gnumake
    pkgs.gcc


    # Haskell
    pkgs.ghc

    # Rust
    pkgs.rustup

    # Containers/DevOps
    pkgs.distrobox
    pkgs.talosctl
    pkgs.kubectl
    pkgs.k9s
    pkgs.kubernetes-helm
    pkgs.skopeo
    pkgs.minikube
    pkgs.ansible
    
    # Nix / NixOS
    pkgs.cntr


    # Security
    pkgs.nmap
    pkgs.gobuster
    unstable.seclists
    pkgs.netcat-openbsd
    pkgs.responder
    pkgs.python313
    pkgs.python313Packages.impacket
  ];

 
  programs.home-manager.enable = true;

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

