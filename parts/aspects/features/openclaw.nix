{ ... }: {
  den.aspects.openclaw = {
    nixos.imports = [ ../../../modules/system/openclaw.nix ];
  };
}
