{ config, lib, pkgs, home-manager, ...}:

{

  programs.zsh.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.neovim = {
    enable = true;
  };


  home.packages = [
     pkgs.nodejs_24
     pkgs.go
  ];

}

