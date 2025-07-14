{ config, lib, pkgs, home-manage, ...}:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      local config = {}

      config.color_scheme = 'Blue Matrix'

      config.font_size = 11.0

      config.window_padding = {
        left = 2,
        right = 2,
        top = 0,
        bottom = 0,
      }

      return config
    '';
  };
}
