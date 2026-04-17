{ config, ... }:
{
  configurations.nixos.Trinity.module = {
    imports = with config.nixosModuleLib; [
      trinityHardware
      core audio networking users secrets htb
      niri steam nvidia vmware qemu docker
      generalPkgs devPkgs devopsPkgs securityPkgs hardwarePkgs aiPkgs
      ({ pkgs, ... }: {
        home-manager.users.netscape.home.packages = [
          pkgs.python313Packages.impacket
        ];
      })
    ];

    networking.hostName = "Trinity";
    system.stateVersion = "25.05";
    netscape.system.networking.firewall.http.enable = true;

    home-manager.users.netscape = {
      imports = with config.homeModuleLib; [
        shell editors git newsboat colors theming foot niri waybar rofi dunst swaylock
      ];
      home.stateVersion = "22.11";
      netscape.home.colors.scheme = "cyberpunk-neon";
      netscape.home.wm.activeCompositor = "niri";
    };
  };
}
