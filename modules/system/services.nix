{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.services;
in
{
  options.netscape.system.services = {
    printing = {
      enable = lib.mkEnableOption "CUPS printing service" // { default = true; };
    };

    scanning = {
      enable = lib.mkEnableOption "SANE scanning (eSCL) support" // { default = true; };
    };

    podman = {
      enable = lib.mkEnableOption "Podman container runtime" // { default = false; };
    };

    docker = {
      enable = lib.mkEnableOption "Docker container runtime" // { default = false; };
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
      assertions = [
        {
          assertion = !(cfg.docker.enable && cfg.podman.enable);
          message = "Docker and Podman cannot both be enabled. Choose one container runtime.";
        }
      ];
    }

    # CUPS printing
    (lib.mkIf cfg.printing.enable {
      services.printing.enable = true;

      hardware.printers.ensurePrinters = [
        {
          name = "Canon_MF650C";
          description = "Canon MF650C Series";
          location = null;
          deviceUri = "ipp://10.0.0.103:631/ipp/print";
          model = "everywhere";
        }
      ];
      hardware.printers.ensureDefaultPrinter = "Canon_MF650C";
    })

    # SANE scanning (eSCL)
    (lib.mkIf cfg.scanning.enable {
      hardware.sane.enable = true;
      hardware.sane.disabledDefaultBackends = [ "escl" ];
      hardware.sane.extraBackends = [
        pkgs.sane-airscan
        (pkgs.writeTextDir "etc/sane.d/airscan.conf" ''
          [devices]
          "Canon_MF650C" = http://10.0.0.103:80/eSCL, escl

          [options]
          discovery = disable
        '')
      ];
      environment.systemPackages = [ pkgs.gscan2pdf ];
    })

    # Docker
    (lib.mkIf cfg.docker.enable {
      users.users.netscape.extraGroups = ["docker"];
      virtualisation.docker.enable = true;
    })

    # Podman
    (lib.mkIf cfg.podman.enable {
      virtualisation.podman = {
        enable = true;
        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
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
