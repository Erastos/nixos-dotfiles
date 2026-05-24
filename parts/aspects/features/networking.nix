{ ... }: {
  den.aspects.networking = {
    nixos.imports = [ ../../../modules/system/networking.nix ];
  };
}
