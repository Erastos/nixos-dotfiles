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
    programs.zsh.envExtra = ''
      export EDITOR="nvim"
      export NVIM_THEME="${cfg.theme}"
    '';

    programs.neovim = {
      enable = true;
      package = pkgs.unstable.neovim-unwrapped;
      withRuby = false;
      withPython3 = false;
    };

    # HM 26.05 switched from init.vim to init.lua; override so it doesn't
    # clobber the hand-managed config at ~/.config/nvim/init.lua.
    xdg.configFile."nvim/init.lua" = lib.mkForce { enable = false; };

    home.packages = [
      pkgs.nodejs_24
      pkgs.go
      pkgs.tree-sitter
    ];

    # Tmux
    programs.tmux = {
      enable = true;
      prefix = "C-a";
      keyMode = "emacs";
      historyLimit = 10000;
      plugins = with pkgs.tmuxPlugins; [
        resurrect
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5'
          '';
        }
        catppuccin
        dracula
      ];
      extraConfig = ''
        # Terminal color support
        set -g default-terminal "tmux-256color"
        set -ga terminal-overrides ",*256col*:RGB"

        # Faster escape (critical for Neovim)
        set -sg escape-time 10

        # Mouse support
        set -g mouse on

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

        # Split panes using | and - (inherit current path)
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        unbind '"'
        unbind %

        # New window inherits current path
        bind c new-window -c "#{pane_current_path}"

        # Pane navigation
        bind h select-pane -L
        bind l select-pane -R
        bind k select-pane -U
        bind j select-pane -D

        # Pane resizing (repeatable)
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5

        # Window cycling (repeatable)
        bind -r C-h previous-window
        bind -r C-l next-window

        # Copy mode
        bind -T copy-mode C-u send -X page-up
        bind -T copy-mode C-f send -X page-down
        bind -T copy-mode v send -X begin-selection
        bind -T copy-mode y send -X copy-selection-and-cancel

        # C-u enters copy mode at page-up (no prefix needed)
        bind C-u copy-mode -u

        # fzf popup bindings
        bind f display-popup -E "zsh -i -c tms"
        bind g display-popup -E "zsh -i -c fs"
        # bind p display-popup -E "zsh -i -c ftpane"

        # Status bar configuration
        set -g status-position bottom
        set -g status-justify left
        set -g status-left-length 200
        set -g status-right-length 200
        set -g status-left "[#S]  "

        # Window title shows running command, auto-renames
        set -g window-status-format " #I:#W "
        set -g window-status-current-format " #I:#W* "
        setw -g automatic-rename on

        # Display git branch and status in right side
        set -g status-right "#(cd #{pane_current_path} && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo \'\') | %H:%M | %a %b %d"
      '';
    };
  };
}
