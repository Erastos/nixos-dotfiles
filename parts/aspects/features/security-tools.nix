{ ... }: {
  den.aspects.security-tools = {
    nixos.imports = [
      ../../../modules/system/htb.nix
      ../../../modules/system/security-extras.nix
    ];
  };
}
