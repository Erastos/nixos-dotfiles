{ config, lib, pkgs, home-manager, ...}:

{
  programs.zsh.shellAliases = {
    up = "sudo nixos-rebuild switch --flake '/home/netscape/nixos-dotfiles#Trinity' -v";
    en = "nvim ~/nixos-dotfiles";
  };
}
