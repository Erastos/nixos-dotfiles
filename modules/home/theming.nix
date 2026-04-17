{ ... }:
{
  homeModuleLib.theming = { config, lib, pkgs, ... }:
  let
    cfg = config.netscape.home.theming;
  in
  {
    options.netscape.home.theming = {
      gtkTheme = lib.mkOption {
        type = lib.types.str;
        default = "Materia-Cyberpunk-Neon";
        description = "GTK theme name";
      };

      gtkThemePackage = lib.mkOption {
        type = lib.types.package;
        default = {
          "Materia-Cyberpunk-Neon" = pkgs.cyberpunk-neon-gtk-theme;
          "Tokyonight-Dark" = pkgs.tokyonight-gtk-theme;
        }.${cfg.gtkTheme} or pkgs.cyberpunk-neon-gtk-theme;
        description = "GTK theme package (auto-derived from gtkTheme name)";
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

    config = {
      home.packages = with pkgs; [
        cyberpunk-neon-gtk-theme
        tokyonight-gtk-theme
        arc-theme
        xdg-desktop-portal
      ];

      gtk = {
        enable = true;
        theme = {
          name = cfg.gtkTheme;
          package = cfg.gtkThemePackage;
        };
      };
    };
  };
}
