{ lib, ... }:

{
  name = "Cyberpunk Neon";
  slug = "cyberpunk-neon";

  # ANSI Colors
  black = "0d0d0d";
  red = "ff2a6d";           # Hot pink
  green = "05d9e8";         # Electric cyan
  yellow = "f9f871";        # Acid yellow
  blue = "7b61ff";          # Electric purple
  magenta = "ff00ff";       # Pure magenta
  cyan = "00fff9";          # Bright cyan
  white = "d1d1e0";

  brightBlack = "1a1a2e";
  brightRed = "ff6ac1";     # Neon pink
  brightGreen = "39ff14";   # Matrix green
  brightYellow = "ffff00";
  brightBlue = "a855f7";
  brightMagenta = "ff77ff";
  brightCyan = "00ffff";
  brightWhite = "ffffff";

  # Special colors
  foreground = "e0e0ff";
  background = "0a0a0f";

  cursor = {
    text = "0a0a0f";
    cursor = "ff2a6d";
  };
}
