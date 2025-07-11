{ config, lib, pkgs, ...}:

{
  programs.nano.enable = false;
  environment.variables.EDITOR = "nvim";
}
