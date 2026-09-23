{ lib, ... }:

{
  name = "Enterprise 2000";
  slug = "enterprise-2000";

  # Bluecurve: Red Hat Linux 8/9 corporate desktop, light chrome, steel-blue accents.
  # Widget/selection colors from neeeeow/Bluecurve gtk-3.0/gtk.css @define-color;
  # remaining ANSI slots are the Tango palette shipped with GNOME-era Bluecurve systems.
  black = "2e3436";
  red = "cc0000";
  green = "4e9a06";
  yellow = "c4a000";
  blue = "4464ac";
  magenta = "75507b";
  cyan = "06989a";
  white = "d3d7cf";

  brightBlack = "555753";
  brightRed = "ef2929";
  brightGreen = "73d216";
  brightYellow = "f57900";
  brightBlue = "5e7ab7";
  brightMagenta = "ad7fa8";
  brightCyan = "34e2e2";
  brightWhite = "eeeeec";

  foreground = "000000";
  background = "ffffff";

  cursor = {
    text = "ffffff";
    cursor = "4464ac";
  };
}
