{ ... }: {
  den.aspects.core = {
    nixos.imports = [ ../../../modules/system/core ];
  };
}
