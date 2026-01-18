{ config, lib, osConfig, ... }:

{
  imports = [
    ./river.nix
    ./niri.nix
    ./waybar.nix
    ./rofi.nix
    ./dunst.nix
    ./swaylock.nix
  ];

  options.netscape.home.wm = {
    river.enable = lib.mkEnableOption "River wayland compositor";
    niri.enable = lib.mkEnableOption "niri scrollable tiling compositor";
    waybar.enable = lib.mkEnableOption "Waybar status bar";
    rofi.enable = lib.mkEnableOption "Rofi application launcher";
    dunst.enable = lib.mkEnableOption "Dunst notification daemon";
    swaylock.enable = lib.mkEnableOption "Swaylock screen locker";
  };

  config = {
    # Enable river by default on laptops
    netscape.home.wm.river.enable = lib.mkDefault (osConfig.netscape.hostType == "laptop");
  };
}
