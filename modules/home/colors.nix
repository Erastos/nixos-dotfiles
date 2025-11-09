{ config, lib, osConfig, ... }:

let
  cfg = config.netscape.home.colors;
  isLaptop = osConfig.netscape.hostType == "laptop";

  colorScheme = {
    black = "120707";
    red = "e03131";
    green = "5e4e4e";
    yellow = "d97a3d";
    blue = "4b3e4b";
    magenta = "b13664";
    cyan = "4d7070";
    white = "e3d9d9";

    brightBlack = "2a1414";
    brightRed = "ff4040";
    brightGreen = "887272";
    brightYellow = "ff9e57";
    brightBlue = "7a627a";
    brightMagenta = "d74b8a";
    brightCyan = "7a9e9e";
    brightWhite = "fff2f2";

    foreground = "e6cfcf";
    background = "1b0c0c";

    cursor = {
      text = "1b0c0c";
      cursor = "ff3b3b";
    };
  };
in
{
  options.netscape.home.colors = {
    enable = lib.mkEnableOption "color scheme configuration" // { default = isLaptop; };
  };

  options.colors = lib.mkOption {
    type = lib.types.attrs;
    default = colorScheme;
    description = "Red color scheme";
  };

  config = lib.mkIf cfg.enable { };
}
