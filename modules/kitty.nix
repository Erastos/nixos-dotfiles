{ config, lib, pkgs, ... }:
{
  imports = [];

  with lib;
  options {
    theme = mkOption {
      type = with types; str;
    };
  };
  config = {
    
  };
}
