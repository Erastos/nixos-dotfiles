{ config, lib, pkgs, home-manager, ... }:

{

  programs.zsh.initContent = ''
    promptinit && prompt powerlevel10k
    source ~/.p10k.zsh
  '';
  programs.zsh.completionInit = "";
  programs.zsh.antidote = {
    enable = true;
    plugins = [
      "sindresorhus/pure  kind:fpath"
      "romkatv/powerlevel10k kind:fpath"
    ];
  };
}

