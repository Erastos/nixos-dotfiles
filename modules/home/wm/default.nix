{ lib, ... }: {
  imports = [
    ./river.nix
    ./niri.nix
    ./waybar.nix
    ./rofi.nix
    ./dunst.nix
    ./swaylock.nix
  ];

  options.netscape.home.wm = {
    river.enable    = lib.mkEnableOption "River wayland compositor";
    niri.enable     = lib.mkEnableOption "niri scrollable tiling compositor";
    niri.profile = lib.mkOption {
      type = lib.types.enum [ "default" "enterprise-2000" ];
      default = "default";
      description = ''
        Niri session profile.
        - default: waybar/rofi/dunst/swaylock shell, global colorscheme as configured.
        - enterprise-2000: Noctalia shell in early-2000s Red Hat Bluecurve styling
          (square corners, solid panels, Luxi Sans, Bluecurve wallpaper), and the
          global colorscheme/GTK theme switch to the Bluecurve palette.
      '';
    };
    waybar.enable   = lib.mkEnableOption "Waybar status bar";
    rofi.enable     = lib.mkEnableOption "Rofi application launcher";
    dunst.enable    = lib.mkEnableOption "Dunst notification daemon";
    swaylock.enable = lib.mkEnableOption "Swaylock screen locker";
  };
}
