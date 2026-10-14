{ den, ... }: {
  den.aspects.Neo = {
    includes = [ den.batteries.hostname den.aspects.shared-nixos ];

    nixos = { ... }: {
      imports = [ ../../hardware/Neo.nix ];
      netscape.system.virtualisation.qemu.enable      = true;
      netscape.system.desktop.sway.enable             = true;
      netscape.system.hardware.intel.enable           = true;
      netscape.system.services.bluetooth.enable       = true;
      netscape.system.hardware.fwupd.enable           = true;
    };
  };
}
