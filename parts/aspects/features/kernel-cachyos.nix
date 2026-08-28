{ den, ... }: {
  den.aspects.cachyos-kernel = {
    nixos = { pkgs, ... }:
      let
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;
      in {
        boot.kernelPackages = kernelPackages.extend (_self: super: {
          vmware = super.vmware.overrideAttrs (old: {
            makeFlags = (old.makeFlags or []) ++ [
              "CC=${super.kernel.stdenv.cc}/bin/clang"
            ];
          });
        });
      };
  };
}
