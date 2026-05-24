{ ... }: {
  den.aspects.hardware = {
    nixos.imports = [ ../../../modules/system/hardware.nix ];
  };
}
