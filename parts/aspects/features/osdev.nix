{ ... }: {
  den.aspects.osdev = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.pkgsCross.i686-embedded.buildPackages.gcc ];
    };
  };
}
