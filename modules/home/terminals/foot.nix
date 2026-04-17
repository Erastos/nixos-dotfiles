{ ... }:
{
  homeModuleLib.foot = { config, ... }:
  {
    programs.foot = {
      enable = true;
      settings = {
        main.font = "Hack Nerd Font:size=12";
        colors = {
          cursor = "${config.colors.cursor.text} ${config.colors.cursor.cursor}";
          foreground = config.colors.foreground;
          background = config.colors.background;
          regular0 = config.colors.black;
          regular1 = config.colors.red;
          regular2 = config.colors.green;
          regular3 = config.colors.yellow;
          regular4 = config.colors.blue;
          regular5 = config.colors.magenta;
          regular6 = config.colors.cyan;
          regular7 = config.colors.white;
          bright0 = config.colors.brightBlack;
          bright1 = config.colors.brightRed;
          bright2 = config.colors.brightGreen;
          bright3 = config.colors.brightYellow;
          bright4 = config.colors.brightBlue;
          bright5 = config.colors.brightMagenta;
          bright6 = config.colors.brightCyan;
          bright7 = config.colors.brightWhite;
        };
      };
    };
  };
}
