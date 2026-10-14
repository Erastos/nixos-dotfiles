{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.theming;
in
{
  options.netscape.home.theming = {
    enable = lib.mkEnableOption "GTK theming" // { default = false; };

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
        "Bluecurve" = pkgs.bluecurve;
        "Bluecurve-Dark" = pkgs.bluecurve;
      }.${cfg.gtkTheme} or pkgs.cyberpunk-neon-gtk-theme;
      description = "GTK theme package (auto-derived from gtkTheme name)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.xdg-desktop-portal ];

    gtk = {
      enable = true;
      theme = {
        name = cfg.gtkTheme;
        package = cfg.gtkThemePackage;
      };
    };
  };
}
