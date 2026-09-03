{ lib, ... }:

{
  name = "Enterprise 2000 Dark";
  slug = "enterprise-2000-dark";

  # Bluecurve: Red Hat Linux 8/9 corporate desktop, navy dark chrome,
  # steel-blue accents. Dark counterpart to enterprise-2000.nix (light);
  # ANSI slots are the Tango palette shipped with GNOME-era Bluecurve
  # systems; surfaces mirror the navy dark palette in modules/home/wm/niri.nix
  # (Noctalia Bluecurve.json dark).
  black = "2e3436";
  red = "cc0000";
  green = "4e9a06";
  yellow = "c4a000";
  blue = "5e7ab7";
  magenta = "75507b";
  cyan = "06989a";
  white = "d3d7cf";

  brightBlack = "555753";
  brightRed = "ef2929";
  brightGreen = "73d216";
  brightYellow = "f57900";
  brightBlue = "7a9ede";
  brightMagenta = "ad7fa8";
  brightCyan = "34e2e2";
  brightWhite = "ffffff";

  foreground = "ffffff";
  background = "1f2a3d";

  cursor = {
    text = "1f2a3d";
    cursor = "ffffff";
  };
}
