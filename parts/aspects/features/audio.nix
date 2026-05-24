{ ... }: {
  den.aspects.audio = {
    nixos.imports = [ ../../../modules/system/audio.nix ];
  };
}
