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

    fwupd = {
      enable = lib.mkEnableOption "Firmware Updater support";
    };
  };

  config = lib.mkMerge [
    # NVIDIA
    (lib.mkIf cfg.nvidia.enable {
      hardware.graphics.enable = true;
      hardware.graphics.enable32Bit = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        open = false;
        modesetting.enable = true;
        nvidiaSettings = true;
        # 595 branch has a GPU-hang bug (NVIDIA #6225934) that freezes 007 First
        # Light on the opening cutscene/level load (NVRM Xid 109 CTX SWITCH
        # TIMEOUT). Fixed in driver 610.43.02+. Pull 610 from nixpkgs-unstable,
        # built against the CachyOS kernel.
        package = (pkgs.unstable.linuxPackagesFor config.boot.kernelPackages.kernel).nvidiaPackages.latest.overrideAttrs (old: {
          # Kernel 7.2.4 still declares gpio_device_get_chip() with a non-const
          # `struct gpio_device *`, but nvidia 610.57.04's __to_hwgpio() compat
          # helper passes a const pointer. clang 21 turns the qualifier discard
          # into an error (nv-linux.h:1706), so drop the const. This is the
          # proprietary `kernel/` tree only; `open = false` above keeps this
          # path in use.
          postPatch = (lib.optionalString (old.postPatch != null) old.postPatch) + ''
            sed -i 's/static inline int __to_hwgpio(const struct gpio_device \*gdev,/static inline int __to_hwgpio(struct gpio_device *gdev,/' kernel/common/inc/nv-linux.h
          '';
        });
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

    # Fwupd
    (lib.mkIf cfg.fwupd.enable {
      services.fwupd.enable = true;
    })
  ];
}
