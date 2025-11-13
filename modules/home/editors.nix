{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.editors;
in
{
  options.netscape.home.editors = {
    enable = lib.mkEnableOption "editor configuration (Neovim and Tmux)" // { default = true; };
    theme = lib.mkOption {
      type = lib.types.str;
      default = "tokyonight";
    };
  };

  config = lib.mkIf cfg.enable {
    # Neovim
    programs.zsh.localVariables = {
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

        # # Unbind the default binding of C-w
        # unbind-key -n C-w
        #
        # # Rebind C-w as a prefix for handling custom subkeys
        # bind-key -n C-w switch-client -T prefix
        #
        # # Bind h with prefix C-w to select the left pane
        # bind-key -T prefix h select-pane -L
        # bind-key -T prefix l select-pane -R
        # bind-key -T prefix j select-pane -D
        # bind-key -T prefix k select-pane -U
      '';
    };
  };
}
