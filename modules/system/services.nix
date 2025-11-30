{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.services;
in
{
  options.netscape.system.services = {
    printing = {
      enable = lib.mkEnableOption "CUPS printing service" // { default = true; };
    };

    podman = {
      enable = lib.mkEnableOption "Podman container runtime" // { default = true; };
    };

    bluetooth = {
      enable = lib.mkEnableOption "Bluetooth" // { default = true; };
    };
  };

  config = lib.mkMerge [
    # CUPS printing
    (lib.mkIf cfg.printing.enable {
      services.printing.enable = true;
    })

    # Podman
    (lib.mkIf cfg.podman.enable {
      virtualisation = {
        podman = {
          enable = true;
          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = true;
          # Required for containers under podman-compose to be able to talk to each other.
          defaultNetwork.settings.dns_enabled = true;
        };
      };
    })

    (lib.mkIf cfg.bluetooth.enable {
      hardware.bluetooth.enable = true;
    })
  ];
}
