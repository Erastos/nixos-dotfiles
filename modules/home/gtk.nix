{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.theming;
in
{
  options.netscape.home.theming = {
    enable = lib.mkEnableOption "GTK/Qt theming" // { default = false; };

    gtkTheme = lib.mkOption {
      type = lib.types.str;
      default = "Materia-Cyberpunk-Neon";
      description = "GTK theme name";
    };

    iconTheme = lib.mkOption {
      type = lib.types.str;
      default = "Papirus-Dark";
      description = "Icon theme name";
    };

    cursorTheme = lib.mkOption {
      type = lib.types.str;
      default = "Bibata-Modern-Classic";
      description = "Cursor theme name";
    };

    cursorSize = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Cursor size";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cyberpunk-neon-gtk-theme
      papirus-icon-theme
      bibata-cursors
      libsForQt5.qtstyleplugin-kvantum
    ];

    gtk = {
      enable = true;
      theme = {
        name = cfg.gtkTheme;
        package = pkgs.cyberpunk-neon-gtk-theme;
      };
      iconTheme = {
        name = cfg.iconTheme;
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = cfg.cursorTheme;
        package = pkgs.bibata-cursors;
        size = cfg.cursorSize;
      };
      font = {
        name = "Hack Nerd Font";
        size = 12;
      };
      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    # Force overwrite existing GTK config files
    xdg.configFile."gtk-3.0/settings.ini".force = true;
    xdg.configFile."gtk-4.0/settings.ini".force = true;
    xdg.configFile."gtk-4.0/gtk.css".force = true;

    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style = {
        name = "kvantum";
        package = pkgs.libsForQt5.qtstyleplugin-kvantum;
      };
    };

    # Cursor theme for Wayland
    home.pointerCursor = {
      name = cfg.cursorTheme;
      package = pkgs.bibata-cursors;
      size = cfg.cursorSize;
      gtk.enable = true;
    };

    # Session variables for Qt apps and GTK theme discovery
    home.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "kvantum";
      XDG_DATA_DIRS = lib.concatStringsSep ":" [
        "${config.home.profileDirectory}/share"
        "/run/current-system/sw/share"
        "/usr/share"
        "\${XDG_DATA_DIRS}"
      ];
    };

    # Systemd user session variables for dbus-activated applications
    systemd.user.sessionVariables = {
      GTK_THEME = cfg.gtkTheme;
      QT_QPA_PLATFORMTHEME = "kvantum";
    };
  };
}
