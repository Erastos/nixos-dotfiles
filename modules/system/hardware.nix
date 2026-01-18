{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.hardware;
in
{
  options.netscape.system.hardware = {
    nvidia = {
      enable = lib.mkEnableOption "NVIDIA graphics drivers";
    };

    intel = {
      enable = lib.mkEnableOption "Intel graphics drivers (modesetting)";
    };

    graphics = {
      enable = lib.mkEnableOption "graphics support" // { default = true; };
    };

    touchpad = {
      enable = lib.mkEnableOption "touchpad support (libinput)" // { default = true; };
    };
  };

  config = lib.mkMerge [
    # Default hardware settings based on host type
    {
      netscape.system.hardware.nvidia.enable = lib.mkDefault (config.netscape.hostType == "desktop");
      netscape.system.hardware.intel.enable = lib.mkDefault (config.netscape.hostType == "laptop");
    }

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
