{ ... }: {
  den.aspects.virtualisation = {
    nixos.imports = [ ../../../modules/system/virtualization.nix ];
  };
}
