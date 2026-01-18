{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.wm;
  colors = config.colors;
in
{
  config = lib.mkIf cfg.swaylock.enable {
    home.packages = with pkgs; [
      swaylock-effects
    ];

    xdg.configFile."swaylock/config".text = ''
      daemonize
      show-failed-attempts
      clock
      indicator
      indicator-radius=100
      indicator-thickness=7
      effect-blur=7x5
      effect-vignette=0.5:0.5
      ring-color=${colors.magenta}
      key-hl-color=${colors.cyan}
      line-color=00000000
      inside-color=00000088
      separator-color=00000000
      grace=2
      fade-in=0.2
      font=Hack Nerd Font
      text-color=${colors.foreground}
      ring-ver-color=${colors.cyan}
      inside-ver-color=00000088
      ring-wrong-color=${colors.red}
      inside-wrong-color=00000088
      ring-clear-color=${colors.yellow}
      inside-clear-color=00000088
    '';
  };
}
