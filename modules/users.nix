{ config, lib, pkgs, ...}:

{
  programs.zsh.enable = true;
  users.users.netscape = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout"];
    shell = pkgs.zsh;
  };
}
