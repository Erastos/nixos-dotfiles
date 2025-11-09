{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.hardware;
  isDesktop = config.netscape.hostType == "desktop";
  isLaptop = config.netscape.hostType == "laptop";
in
{
  options.netscape.system.hardware = {
    nvidia = {
      enable = lib.mkEnableOption "NVIDIA graphics drivers" // { default = isDesktop; };
    };

    intel = {
      enable = lib.mkEnableOption "Intel graphics drivers (modesetting)" // { default = isLaptop; };
    };

    graphics = {
      enable = lib.mkEnableOption "graphics support" // { default = true; };
    };

    touchpad = {
      enable = lib.mkEnableOption "touchpad support (libinput)" // { default = true; };
    };
  };

  config = lib.mkMerge [
    # NVIDIA
    (lib.mkIf cfg.nvidia.enable {
      hardware.graphics.enable = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        modesetting.enable = true;
        open = true;
        nvidiaSettings = true;
      };
    })

    # Intel
    (lib.mkIf cfg.intel.enable {
      services.xserver.videoDrivers = [ "modesetting" ];
    })

    # Graphics (general)
    (lib.mkIf (cfg.graphics.enable && !cfg.nvidia.enable) {
      hardware.graphics.enable = true;
    })

    # Touchpad
    (lib.mkIf cfg.touchpad.enable {
      services.libinput.enable = true;
    })
  ];
}
