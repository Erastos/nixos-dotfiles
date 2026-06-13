{ den, lib, ... }: {
  den.aspects.cachyos-kernel = {
    nixos = { pkgs, ... }: {
      boot.kernelPackages = pkgs.cachyosKernels.linux-cachyos-bore-zen4;
    };
  };
}
