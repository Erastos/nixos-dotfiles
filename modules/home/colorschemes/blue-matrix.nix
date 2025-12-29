{ lib, ... }:

{
  name = "Blue Matrix";
  slug = "blue-matrix";

  # ANSI Colors
  black = "101116";
  red = "ff5680";
  green = "00ff9c";
  yellow = "fffc58";
  blue = "00b0ff";
  magenta = "d57bff";
  cyan = "76c1ff";
  white = "c7c7c7";

  brightBlack = "686868";
  brightRed = "ff6e67";
  brightGreen = "5ffa68";
  brightYellow = "fffc67";
  brightBlue = "6871ff";
  brightMagenta = "d682ec";
  brightCyan = "60fdff";
  brightWhite = "ffffff";

  # Special colors
  foreground = "00a2ff";
  background = "101116";

  cursor = {
    text = "101116";
    cursor = "76ff9f";
  };
}
