{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.wm;
  colors = config.colors;
in
{
  config = lib.mkIf cfg.rofi.enable {
    home.packages = with pkgs; [
      rofi-power-menu
    ];

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      terminal = "foot";
      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
          bg = mkLiteral "#${colors.background}";
          bg-alt = mkLiteral "#${colors.brightBlack}";
          fg = mkLiteral "#${colors.foreground}";
          accent = mkLiteral "#${colors.magenta}";
          accent-alt = mkLiteral "#${colors.cyan}";
          urgent = mkLiteral "#${colors.red}";

          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@fg";
          margin = 0;
          padding = 0;
          spacing = 0;
        };

        window = {
          location = mkLiteral "center";
          width = 600;
          border-radius = mkLiteral "8px";
          background-color = mkLiteral "@bg";
          border = mkLiteral "2px solid";
          border-color = mkLiteral "@accent";
        };

        mainbox = {
          padding = mkLiteral "12px";
        };

        inputbar = {
          background-color = mkLiteral "@bg-alt";
          border-radius = mkLiteral "4px";
          padding = mkLiteral "8px 12px";
          spacing = mkLiteral "8px";
          children = map mkLiteral [ "prompt" "entry" ];
        };

        prompt = {
          text-color = mkLiteral "@accent";
        };

        entry = {
          placeholder = "Search...";
          placeholder-color = mkLiteral "@fg";
        };

        message = {
          margin = mkLiteral "12px 0 0 0";
          border-radius = mkLiteral "4px";
          background-color = mkLiteral "@bg-alt";
        };

        textbox = {
          padding = mkLiteral "8px";
        };

        listview = {
          margin = mkLiteral "12px 0 0 0";
          lines = 8;
          columns = 1;
          fixed-height = false;
        };

        element = {
          padding = mkLiteral "8px";
          spacing = mkLiteral "8px";
          border-radius = mkLiteral "4px";
        };

        "element normal active" = {
          text-color = mkLiteral "@accent-alt";
        };

        "element selected normal" = {
          background-color = mkLiteral "@accent";
          text-color = mkLiteral "@bg";
        };

        "element selected active" = {
          background-color = mkLiteral "@accent-alt";
          text-color = mkLiteral "@bg";
        };

        element-icon = {
          size = mkLiteral "1em";
          vertical-align = mkLiteral "0.5";
        };

        element-text = {
          text-color = mkLiteral "inherit";
        };
      };
    };
  };
}
