{ config, lib, pkgs, home-manager, ...}:

{
  program.zsh.shellAliases = {
    update = "sudo nixos-rebuild switch --flake '/home/netscape/nixos-dotfiles#Trinity'";
  };
}
