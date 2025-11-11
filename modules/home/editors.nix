{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.editors;
in
{
  options.netscape.home.editors = {
    enable = lib.mkEnableOption "editor configuration (Neovim and Tmux)" // { default = true; };
    theme = lib.mkOption {
      type = lib.types.str;
      default = "onedark";
    };
  };

  config = lib.mkIf cfg.enable {
    # Neovim
    programs.zsh.sessionVariables = {
      EDITOR = "nvim";
      NVIM_THEME = cfg.theme;
    };

    programs.neovim = {
      enable = true;
    };

    home.packages = [
      pkgs.nodejs_24
      pkgs.go
    ];

    # Tmux
    programs.tmux = {
      enable = true;
      prefix = "C-a";
      historyLimit = 10000;
      plugins = with pkgs.tmuxPlugins; [
        resurrect
      ];
      extraConfig = ''
        # remap prefix from 'C-b' to 'C-a'
        # unbind C-b
        # set-option -g prefix C-a
        # bind-key C-a send-prefix

        # split panes using | and -
        bind | split-window -h
        bind - split-window -v
        unbind '"'
        unbind %

        bind h select-pane -L
        bind l select-pane -R
        bind k select-pane -U
        bind j select-pane -D

        bind -T copy-mode u send -X page-up
        bind -T copy-mode f send -X page-down

        bind C-u copy-mode -u
      '';
    };
  };
}
