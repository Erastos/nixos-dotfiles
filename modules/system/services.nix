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
      enable = lib.mkEnableOption "Bluetooth";
    };

    dropbox = {
      enable = lib.mkEnableOption "Dropbox" // { default = true; };
    };
  };

  config = lib.mkMerge [
    # Default services based on host type
    {
      netscape.system.services.bluetooth.enable = lib.mkDefault (config.netscape.hostType == "laptop");
    }

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

    (lib.mkIf cfg.dropbox.enable {
      environment.systemPackages = with pkgs; [
        dropbox
        dropbox-cli
      ];

      systemd.user.services.dropbox = {
          name = "dropbox";
          description = "Dropbox File Sync Daemon";
          enable = true;
          wantedBy = [ "default.target" ];
          wants = ["network-online.target"];
          after = ["network-online.target"];

          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.dropbox}/bin/dropbox";
            Restart = "on-failure";
            RestartSec = 5;
            PrivateTmp = true;
            ProtectSystem = "full";
            Nice = 10;
            StandardOutput = "journal";
            StandardError = "journal";
          };
      };
    })
  ];
}
