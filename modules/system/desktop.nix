{ config, lib, pkgs, unstable, ... }:

let
  cfg = config.netscape.system.desktop;
  isDesktop = config.netscape.hostType == "desktop";
  isLaptop = config.netscape.hostType == "laptop";
in
{
  options.netscape.system.desktop = {
    plasma = {
      enable = lib.mkEnableOption "KDE Plasma 6 desktop" // { default = isDesktop; };
    };

    sway = {
      enable = lib.mkEnableOption "Sway compositor" // { default = isLaptop; };
    };

    steam = {
      enable = lib.mkEnableOption "Steam gaming platform" // { default = isDesktop; };
    };
  };

  config = lib.mkMerge [
    # Plasma 6
    (lib.mkIf cfg.plasma.enable {
      services.xserver.enable = true;
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;
      environment.systemPackages = with pkgs; [
        kdePackages.kcalc
        kdePackages.sddm-kcm
        hardinfo2
        wayland-utils
        wl-clipboard
      ];
    })

    # Sway
    (lib.mkIf cfg.sway.enable {
      programs.sway.enable = true;
    })

    # Steam
    (lib.mkIf cfg.steam.enable {
      programs.steam.enable = true;
      programs.steam.extraCompatPackages = [ unstable.proton-ge-bin ];
      programs.steam.gamescopeSession.enable = true;
      programs.steam.protontricks.enable = true;
    })
  ];
}
