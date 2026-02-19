{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.desktop;
  hwCfg = config.netscape.system.hardware;
in
{
  options.netscape.system.desktop = {
    plasma = {
      enable = lib.mkEnableOption "KDE Plasma 6 desktop";
    };

    sway = {
      enable = lib.mkEnableOption "Sway compositor";
    };

    niri = {
      enable = lib.mkEnableOption "niri scrollable tiling compositor";
    };

    steam = {
      enable = lib.mkEnableOption "Steam gaming platform";
    };
  };

  config = lib.mkMerge [
    # Default desktop settings based on host type
    {
      netscape.system.desktop.sway.enable = lib.mkDefault (config.netscape.hostType == "laptop");
      netscape.system.desktop.steam.enable = lib.mkDefault (config.netscape.hostType == "desktop");
    }

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
      xdg.terminal-exec = {
        enable = true;
        settings = {
          default = [
            "foot.desktop"
          ];
        };
      };
    })

    # Sway
    (lib.mkIf cfg.sway.enable {
      programs.sway.enable = true;
    })

    # niri
    (lib.mkIf cfg.niri.enable {
      programs.niri.enable = true;
      programs.xwayland.enable = true;
      programs.dconf.enable = true;

      # SDDM with Wayland
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "sddm-astronaut-theme";
        extraPackages = with pkgs; [
          kdePackages.qtmultimedia
        ];
      };

      # XDG Portal for screen sharing and file dialogs
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      };

      # Polkit authentication agent
      security.polkit.enable = true;
      systemd.user.services.polkit-gnome-agent = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      # System packages for niri
      environment.systemPackages = with pkgs; [
        wayland-utils
        wl-clipboard
        xdg-utils
        qt5.qtwayland
        qt6.qtwayland
        polkit_gnome
        sddm-sugar-dark
        sddm-astronaut
        xwayland-satellite
      ];

      # NVIDIA Wayland environment variables
      environment.sessionVariables = lib.mkIf hwCfg.nvidia.enable {
        LIBVA_DRIVER_NAME = "nvidia";
        XDG_SESSION_TYPE = "wayland";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        WLR_NO_HARDWARE_CURSORS = "1";
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
      };

      # Default terminal for xdg-terminal-exec
      xdg.terminal-exec = {
        enable = true;
        settings = {
          default = [ "foot.desktop" ];
        };
      };
    })

    # Steam
    (lib.mkIf cfg.steam.enable {
      programs.steam.enable = true;
      programs.steam.extraCompatPackages = [ pkgs.unstable.proton-ge-bin ];
      programs.steam.gamescopeSession.enable = true;
      programs.steam.protontricks.enable = true;
      programs.gamemode.enable = true;
    })
  ];
}
