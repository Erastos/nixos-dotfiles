{ config, lib, pkgs, ...}:

{
  options = {
    systemName = lib.mkOption {
      type = lib.types.str;
      example = "Neo";
      description = "Name of the NixOS system configuration (used in flake reference)";
    };
  };

  config = { };
}
