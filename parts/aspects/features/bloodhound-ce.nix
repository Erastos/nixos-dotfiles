{ ... }: {
  den.aspects.bloodhound-ce = {
    nixos.imports = [ ../../../modules/system/bloodhound-ce.nix ];
  };
}
