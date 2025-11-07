{ config, lib, pkgs, home-manager, osConfig, ...}:

{
  programs.zsh.shellAliases = {
    up = "sudo nixos-rebuild switch --flake '/home/netscape/nixos-dotfiles#${osConfig.systemName}' -v";
    boot = "sudo nixos-rebuild boot --flake '/home/netscape/nixos-dotfiles#${osConfig.systemName}' -v";
    en = "nvim ~/nixos-dotfiles";
    nix-shell = "nix-shell --command 'export SHELL=/bin/zsh; zsh'";
  };
}
