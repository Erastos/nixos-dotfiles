{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.netscape.home.shell;
in
{
  options.netscape.home.shell = {
    enable = lib.mkEnableOption "Zsh shell configuration" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    # Ensure SOPS age directory exists
    home.file.".config/sops/age/.keep".text = ''
      # This directory stores age keys for SOPS encryption
      # Place your converted SSH host key here as keys.txt
    '';

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
        up = "sudo nixos-rebuild switch --flake '${config.home.homeDirectory}/nixos-dotfiles#${osConfig.netscape.systemName}' -v";
        boot = "sudo nixos-rebuild boot --flake '${config.home.homeDirectory}/nixos-dotfiles#${osConfig.netscape.systemName}' -v";
        en = "nvim ${config.home.homeDirectory}/nixos-dotfiles";
        eco = "nvim ${config.xdg.configHome}/nvim";
        nix-shell = "nix-shell --command 'export SHELL=/bin/zsh; zsh'";
        secrets = "cd ${config.home.homeDirectory}/nixos-dotfiles && sops secrets/secrets.yaml";
      } // lib.optionalAttrs osConfig.netscape.system.htb.enable {
        htb = "sudo systemctl start htb-update.service";
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
