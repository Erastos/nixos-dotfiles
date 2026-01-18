{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.netscape.home.terminals;
in
{
  options.netscape.home.terminals = {
    wezterm = {
      enable = lib.mkEnableOption "Wezterm terminal emulator" // { default = true; };
    };

    foot = {
      enable = lib.mkEnableOption "Foot terminal emulator" // { default = true; };
    };
  };

  config = lib.mkMerge [
    # Wezterm
    (lib.mkIf cfg.wezterm.enable {
      programs.wezterm = {
        enable = true;
        enableZshIntegration = true;
        extraConfig = ''
          local config = {}

          -- Custom colorscheme from NixOS config
          config.colors = {
            foreground = "#${config.colors.foreground}",
            background = "#${config.colors.background}",
            cursor_bg = "#${config.colors.cursor.cursor}",
            cursor_fg = "#${config.colors.cursor.text}",

            ansi = {
              "#${config.colors.black}",
              "#${config.colors.red}",
              "#${config.colors.green}",
              "#${config.colors.yellow}",
              "#${config.colors.blue}",
              "#${config.colors.magenta}",
              "#${config.colors.cyan}",
              "#${config.colors.white}",
            },

            brights = {
              "#${config.colors.brightBlack}",
              "#${config.colors.brightRed}",
              "#${config.colors.brightGreen}",
              "#${config.colors.brightYellow}",
              "#${config.colors.brightBlue}",
              "#${config.colors.brightMagenta}",
              "#${config.colors.brightCyan}",
              "#${config.colors.brightWhite}",
            },
          }

          config.font_size = 11.0

          config.window_padding = {
            left = 2,
            right = 2,
            top = 0,
            bottom = 0,
          }

          return config
        '';
      };
    })

    # Foot (requires colors module)
    (lib.mkIf cfg.foot.enable {
      programs.foot = {
        enable = true;
        settings = {
          main = {
            font = "Hack Nerd Font:size=12";
          };
          # cursor = {
          #   color = "${config.colors.cursor.text} ${config.colors.cursor.cursor}"; # <text> <cursor>
          # };
          colors = {
            cursor = "${config.colors.cursor.text} ${config.colors.cursor.cursor}";
            foreground = config.colors.foreground;
            background = config.colors.background;
            regular0 = config.colors.black; # black
            regular1 = config.colors.red; # red
            regular2 = config.colors.green; # green
            regular3 = config.colors.yellow; # yellow
            regular4 = config.colors.blue; # blue
            regular5 = config.colors.magenta; # magenta
            regular6 = config.colors.cyan; # cyan
            regular7 = config.colors.white; # white
            bright0 = config.colors.brightBlack; # bright black
            bright1 = config.colors.brightRed; # bright red
            bright2 = config.colors.brightGreen; # bright green
            bright3 = config.colors.brightYellow; # bright yellow
            bright4 = config.colors.brightBlue; # bright blue
            bright5 = config.colors.brightMagenta; # bright magenta
            bright6 = config.colors.brightCyan; # bright cyan
            bright7 = config.colors.brightWhite; # bright white
          };
        };
      };
    })
  ];
}
