{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.netscape.home.shell;
in
{
  options.netscape.home.shell = {
    enable = lib.mkEnableOption "Zsh shell configuration" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      defaultKeymap = "emacs";
      history.size = 1000;
      history.save = 100000;
      history.share = false;

      zprof.enable = false;

      # Aliases
      shellAliases = {
        up = "sudo nixos-rebuild switch --flake '/home/netscape/nixos-dotfiles#${osConfig.netscape.systemName}' -v";
        boot = "sudo nixos-rebuild boot --flake '/home/netscape/nixos-dotfiles#${osConfig.netscape.systemName}' -v";
        en = "nvim ~/nixos-dotfiles";
        eco = "nvim ~/.config/nvim";
        nix-shell = "nix-shell --command 'export SHELL=/bin/zsh; zsh'";
      };

      # Powerlevel 10K Theme
      initContent = ''
        promptinit && prompt powerlevel10k
        source ~/.p10k.zsh
      '';

      completionInit = "";

      # Antidote plugin manager
      antidote = {
        enable = true;
        plugins = [
          "sindresorhus/pure  kind:fpath"
          "romkatv/powerlevel10k kind:fpath"
        ];
      };
    };
  };
}
