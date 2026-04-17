{ lib, ... }:
{
  options.nixosModuleLib = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = {};
    description = "Library of reusable NixOS deferred modules";
  };

  options.homeModuleLib = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = {};
    description = "Library of reusable home-manager deferred modules";
  };
}
