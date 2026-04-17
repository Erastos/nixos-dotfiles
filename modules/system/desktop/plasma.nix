{ ... }:
{
  nixosModuleLib.plasma = { pkgs, ... }:
  {
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
      settings.default = [ "foot.desktop" ];
    };
  };
}
