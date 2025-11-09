{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.core;
in
{
  options.netscape = {
    # System identification
    systemName = lib.mkOption {
      type = lib.types.str;
      example = "Neo";
      description = "Name of the NixOS system configuration (used in flake reference)";
    };

    hostType = lib.mkOption {
      type = lib.types.enum [ "desktop" "laptop" ];
      example = "laptop";
      description = "Type of host system (desktop or laptop)";
    };

    system.core = {
      enable = lib.mkEnableOption "core system configuration" // { default = true; };

      boot = {
        enable = lib.mkEnableOption "systemd-boot bootloader" // { default = true; };
      };

      kernel = {
        enable = lib.mkEnableOption "latest Linux kernel" // { default = true; };
      };

      time = {
        enable = lib.mkEnableOption "timezone configuration" // { default = true; };
        timeZone = lib.mkOption {
          type = lib.types.str;
          default = "America/New_York";
          description = "System timezone";
        };
      };

      locale = {
        enable = lib.mkEnableOption "locale configuration" // { default = true; };
      };

      fonts = {
        enable = lib.mkEnableOption "Nerd Fonts" // { default = true; };
      };

      nix = {
        enable = lib.mkEnableOption "Nix configuration (flakes, experimental features, lix)" // { default = true; };
      };

      editor = {
        enable = lib.mkEnableOption "default editor configuration" // { default = true; };
      };

      basePackages = {
        enable = lib.mkEnableOption "base system packages" // { default = true; };
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Boot loader
    (lib.mkIf cfg.boot.enable {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    })

    # Kernel
    (lib.mkIf cfg.kernel.enable {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    })

    # Time
    (lib.mkIf cfg.time.enable {
      time.timeZone = cfg.time.timeZone;
      environment.systemPackages = with pkgs; [ ntp ];
    })

    # Locale
    (lib.mkIf cfg.locale.enable {
      i18n.defaultLocale = "en_US.UTF-8";
      console = {
        font = "Lat2-Terminus16";
        useXkbConfig = true;
      };
    })

    # Fonts
    (lib.mkIf cfg.fonts.enable {
      fonts.packages = [
        pkgs.nerd-fonts.hack
        pkgs.nerd-fonts.blex-mono
      ];
    })

    # Nix configuration
    (lib.mkIf cfg.nix.enable {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.package = pkgs.lix;
    })

    # Editor
    (lib.mkIf cfg.editor.enable {
      programs.nano.enable = false;
      environment.variables.EDITOR = "nvim";
    })

    # Base packages
    (lib.mkIf cfg.basePackages.enable {
      environment.systemPackages = with pkgs; [ wget ];
    })
  ]);
}
