{ ... }: {
  den.aspects.services = {
    nixos.imports = [ ../../../modules/system/services.nix ];
  };
}
