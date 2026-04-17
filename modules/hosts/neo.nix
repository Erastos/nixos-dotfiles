{ config, ... }:
{
  configurations.nixos.Neo.module = {
    imports = with config.nixosModuleLib; [
      neoHardware
      core audio networking users secrets htb
      intel touchpad bluetooth
      qemu docker
      generalPkgs devPkgs devopsPkgs securityPkgs hardwarePkgs aiPkgs
      ({ pkgs, ... }: {
        home-manager.users.netscape.home.packages = with pkgs; [
          pulsemixer
          acpi
          dmenu
          wl-clipboard
        ];
      })
    ];

    networking.hostName = "Neo";
    system.stateVersion = "25.05";
    netscape.system.networking.firewall.http.enable = true;

    home-manager.users.netscape = {
      imports = with config.homeModuleLib; [
        shell editors git newsboat colors theming foot river waybar rofi dunst swaylock
      ];
      home.stateVersion = "22.11";
      netscape.home.theming.gtkTheme = "Tokyonight-Dark";
      netscape.home.wm.activeCompositor = "river";
    };
  };
}
