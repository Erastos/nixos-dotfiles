{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = false;
  };

  services.xserver.desktopManager.gnome.enable = true;
}
