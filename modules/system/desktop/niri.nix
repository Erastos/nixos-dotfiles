{ ... }:
{
  nixosModuleLib.niri = { pkgs, ... }:
  {
    programs.niri.enable = true;
    programs.xwayland.enable = true;
    programs.dconf.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "sddm-astronaut-theme";
      extraPackages = with pkgs; [ kdePackages.qtmultimedia ];
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };

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

    xdg.terminal-exec = {
      enable = true;
      settings.default = [ "foot.desktop" ];
    };
  };
}
