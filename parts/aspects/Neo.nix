{ den, ... }: {
  den.aspects.Neo = {
    includes = [ den.batteries.hostname den.aspects.shared-nixos ];
    nixos = { ... }: {
      imports = [ ../../hardware/Neo.nix ];
      netscape.system.networking.firewall.http.enable = true;
      netscape.system.htb.enable                      = true;
      netscape.system.virtualisation.qemu.enable      = true;
      netscape.system.services.docker.enable          = true;
      netscape.system.desktop.sway.enable             = true;
      netscape.system.hardware.intel.enable           = true;
      netscape.system.services.bluetooth.enable       = true;
    };
  };
}
