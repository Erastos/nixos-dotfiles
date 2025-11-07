{ config, pkgs, unstable, home-manager, ...}:

{

  home.stateVersion = "22.11";


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
    pkgs.playerctl
    pkgs.dig
    pkgs.openssl
    pkgs.libreoffice-fresh
    pkgs.unzip
    pkgs.emacs
    pkgs.ripgrep
    unstable.jujutsu
    pkgs.usbutils
    pkgs.obsidian
    pkgs.telegram-desktop
    pkgs.lsof

    # C/C++
    pkgs.cmake
    pkgs.gnumake
    pkgs.gcc

    # Haskell
    pkgs.ghc

    # Rust
    pkgs.rustup

    # Containers/DevOps
    pkgs.kubectl
    unstable.k9s
    pkgs.kubernetes-helm
    pkgs.skopeo
    pkgs.ansible
    pkgs.podman
    pkgs.terraform
    pkgs.packer
    
    # Nix / NixOS
    pkgs.cntr

    # Security
    pkgs.wireshark
    pkgs.nmap
    unstable.netexec
    pkgs.gobuster
    unstable.seclists
    pkgs.netcat-openbsd
    pkgs.responder
    pkgs.python313
    pkgs.python313Packages.impacket
    unstable.metasploit

    # Hardware
    pkgs.arduino-ide
  ];


  programs.home-manager.enable = true;

}

