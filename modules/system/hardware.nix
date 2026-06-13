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
    # NVIDIA
    (lib.mkIf cfg.nvidia.enable {
      hardware.graphics.enable = true;
      hardware.graphics.enable32Bit = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        open = true;
        modesetting.enable = true;
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
      hardware.graphics.enable32Bit = true;
    })

    # Touchpad
    (lib.mkIf cfg.touchpad.enable {
      services.libinput.enable = true;
    })
  ];
}
