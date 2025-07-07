{ config, lib, pkgs, home-manager, ...}:

{
  programs.zsh.shellAliases = {
    update = "sudo nixos-rebuild switch --flake '/home/netscape/nixos-dotfiles#Trinity'";
  };
}
