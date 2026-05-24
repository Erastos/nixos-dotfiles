{ ... }: {
  den.aspects.secrets = {
    nixos.imports = [ ../../../modules/system/secrets.nix ];
  };
}
