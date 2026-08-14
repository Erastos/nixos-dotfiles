{ den, ... }: {
  den.aspects.Trinity = {
    includes = [ den.batteries.hostname den.aspects.shared-nixos ];
    nixos = { ... }: {
      imports = [
        ../../hardware/Trinity.nix
        ../../modules/system/hermes.nix
      ];
      netscape.system.networking.firewall.http.enable = true;
      netscape.system.htb.enable                      = true;
      netscape.system.htb.vpn.enable                  = true;
      netscape.system.virtualisation.vmware.enable    = true;
      netscape.system.virtualisation.qemu.enable      = true;
      netscape.system.desktop.plasma.enable           = false;
      netscape.system.desktop.niri.enable             = true;
      netscape.system.desktop.steam.enable            = true;
      netscape.system.services.docker.enable          = true;
      netscape.system.hardware.nvidia.enable          = true;
      programs.nix-ld.enable                          = true;
    };
  };
}
