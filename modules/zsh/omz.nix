{ config, lib, pkgs, home-manager, ...}:

{
  programs.zsh.oh-my-zsh = {
    enable = true;
    plugins = [ "git"  ];
    theme = "agnoster";
  };


}
