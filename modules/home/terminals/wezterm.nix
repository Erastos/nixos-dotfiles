{ ... }:
{
  homeModuleLib.wezterm = { config, pkgs, ... }:
  {
    programs.wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = ''
        local config = {}

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
        config.window_padding = { left = 2, right = 2, top = 0, bottom = 0 }

        return config
      '';
    };
  };
}
