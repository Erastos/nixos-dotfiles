{ den, ... }: {
  den.aspects.Trinity = {
    includes = [ den.batteries.hostname den.aspects.shared-nixos den.aspects.cachyos-kernel ];

    nixos = { ... }: {
      imports = [ ../../hardware/Trinity.nix ];
      netscape.system.virtualisation.vmware.enable = true;
      netscape.system.virtualisation.qemu.enable   = true;
      netscape.system.desktop.niri.enable          = true;
      netscape.system.desktop.steam.enable         = true;
      netscape.system.bloodhound-ce.enable         = true;
      netscape.system.hardware.nvidia.enable       = true;
      programs.nix-ld.enable                       = true;
    };
  };
}
