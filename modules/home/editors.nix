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
    tmuxTheme = lib.mkOption {
      type = lib.types.enum [ "catppuccin-mocha" "catppuccin-macchiato" "catppuccin-frappe" "catppuccin-latte" "dracula" ];
      default = "catppuccin-mocha";
      description = "Tmux color theme";
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
      keyMode = "emacs";
      historyLimit = 10000;
      plugins = with pkgs.tmuxPlugins; [
        resurrect
        catppuccin
        dracula
      ];
      extraConfig = ''
        # Terminal color support
        set -g default-terminal "tmux-256color"
        set -ga terminal-overrides ",*256col*:RGB"

        # Theme selection
        ${if cfg.tmuxTheme == "catppuccin-mocha" then ''
          run ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin-mocha.tmux
        '' else if cfg.tmuxTheme == "catppuccin-macchiato" then ''
          run ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin-macchiato.tmux
        '' else if cfg.tmuxTheme == "catppuccin-frappe" then ''
          run ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin-frappe.tmux
        '' else if cfg.tmuxTheme == "catppuccin-latte" then ''
          run ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin-latte.tmux
        '' else if cfg.tmuxTheme == "dracula" then ''
          run ${pkgs.tmuxPlugins.dracula}/share/tmux-plugins/dracula/dracula.tmux
        '' else ""}

        # Reload configuration
        bind R source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

        # Send C-a to shell when pressed twice
        bind C-a send-keys C-a

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

        # Status bar configuration
        set -g status-position bottom
        set -g status-justify left
        set -g status-left-length 200
        set -g status-right-length 200
        set -g status-left "[#S]  "

        # Display git branch and status in right side
        set -g status-right "#(cd #{pane_current_path} && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo \'\') | %H:%M | %a %b %d"
      '';
    };
  };
}
