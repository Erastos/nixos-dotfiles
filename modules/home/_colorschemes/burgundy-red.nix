{ lib, ... }:

{
  name = "Burgundy Red";
  slug = "burgundy-red";

  # ANSI Colors
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

  # Special colors
  foreground = "e6cfcf";
  background = "1b0c0c";

  cursor = {
    text = "1b0c0c";
    cursor = "ff3b3b";
  };
}
