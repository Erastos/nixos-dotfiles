{ config, lib, pkgs, home-manager, ...}:

{

programs.tmux = {
  enable = true;
  prefix = "C-a";
  extraConfig = ''
  # split panes using | and -
  bind | split-window -h
  bind - split-window -v
  unbind '"'
  unbind %  

  # switch panes using Alt-arrow without prefix
  bind h select-pane -L
  bind l select-pane -R
  bind k select-pane -U
  bind j select-pane -D
  '';
};

}
