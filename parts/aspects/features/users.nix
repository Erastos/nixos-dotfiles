{ ... }: {
  den.aspects.users = {
    nixos.imports = [ ../../../modules/system/users.nix ];
  };
}
