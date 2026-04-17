{ ... }:
{
  homeModuleLib.shell = { config, lib, pkgs, osConfig, ... }:
  {
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

      shellAliases = {
        up = "sudo nixos-rebuild switch --flake '${config.home.homeDirectory}/nixos-dotfiles#${osConfig.networking.hostName}' -v";
        boot = "sudo nixos-rebuild boot --flake '${config.home.homeDirectory}/nixos-dotfiles#${osConfig.networking.hostName}' -v";
        en = "nvim ${config.home.homeDirectory}/nixos-dotfiles";
        eco = "nvim ${config.xdg.configHome}/nvim";
        nix-shell = "nix-shell --command 'export SHELL=/bin/zsh; zsh'";
        secrets = "cd ${config.home.homeDirectory}/nixos-dotfiles && sops secrets/secrets.yaml";
        k = "kubectl";
        htb = "sudo systemctl start htb-update.service";
      };

      initContent = ''
        promptinit && prompt powerlevel10k
        source ~/.p10k.zsh

        dev() {
          local shell="''${1:?Usage: dev <shell-name>}"
          shift
          nix develop --no-pure-eval "/home/netscape/nixos-dotfiles#''${shell}" "$@"
        }
      '';

      completionInit = "";

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
