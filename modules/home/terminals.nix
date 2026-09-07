{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.netscape.home.terminals;
  terminalColors = config.colors // (config.colors.terminal or {});
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
            foreground = "#${terminalColors.foreground}",
            background = "#${terminalColors.background}",
            cursor_bg = "#${terminalColors.cursor.cursor}",
            cursor_fg = "#${terminalColors.cursor.text}",

            ansi = {
              "#${terminalColors.black}",
              "#${terminalColors.red}",
              "#${terminalColors.green}",
              "#${terminalColors.yellow}",
              "#${terminalColors.blue}",
              "#${terminalColors.magenta}",
              "#${terminalColors.cyan}",
              "#${terminalColors.white}",
            },

            brights = {
              "#${terminalColors.brightBlack}",
              "#${terminalColors.brightRed}",
              "#${terminalColors.brightGreen}",
              "#${terminalColors.brightYellow}",
              "#${terminalColors.brightBlue}",
              "#${terminalColors.brightMagenta}",
              "#${terminalColors.brightCyan}",
              "#${terminalColors.brightWhite}",
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
          colors-dark = {
            cursor = "${terminalColors.cursor.text} ${terminalColors.cursor.cursor}";
            foreground = terminalColors.foreground;
            background = terminalColors.background;
            regular0 = terminalColors.black; # black
            regular1 = terminalColors.red; # red
            regular2 = terminalColors.green; # green
            regular3 = terminalColors.yellow; # yellow
            regular4 = terminalColors.blue; # blue
            regular5 = terminalColors.magenta; # magenta
            regular6 = terminalColors.cyan; # cyan
            regular7 = terminalColors.white; # white
            bright0 = terminalColors.brightBlack; # bright black
            bright1 = terminalColors.brightRed; # bright red
            bright2 = terminalColors.brightGreen; # bright green
            bright3 = terminalColors.brightYellow; # bright yellow
            bright4 = terminalColors.brightBlue; # bright blue
            bright5 = terminalColors.brightMagenta; # bright magenta
            bright6 = terminalColors.brightCyan; # bright cyan
            bright7 = terminalColors.brightWhite; # bright white
          };
        };
      };
    })
  ];
}
