{ config, lib, pkgs, unstable, ... }:

let
  cfg = config.netscape.packages.general;
in
{
  options.netscape.packages.general = {
    enable = lib.mkEnableOption "general utility packages" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.netscape = {
      home.packages = with pkgs; [
        gnupg
        discord
        spotify
        fastfetch
        whois
        dropbox
        wezterm
        firefox
        w3m
        pciutils
        arandr
        openvpn
        htop
        file
        chromium
        vim
        playerctl
        dig
        openssl
        libreoffice-fresh
        unzip
        emacs
        ripgrep
        unstable.jujutsu
        usbutils
        obsidian
        telegram-desktop
        lsof
        pamixer
        remmina
        p7zip
      ];
    };
  };
}
