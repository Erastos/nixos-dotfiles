{ ... }: {
  den.aspects.desktop = {
    nixos.imports = [ ../../../modules/system/desktop ];
  };
}
