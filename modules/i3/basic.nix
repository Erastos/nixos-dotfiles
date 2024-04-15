{ config, lib, pkgs, ... }:
let 
  mod = "Mod4";
in {
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      modifier = mod;
      fonts = ["DejaVu Sans Mono, FontAwesome 6"];
      gaps.inner = 10;

      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec kitty";
        "${mod}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
        # "${mod}+x" = "exec sh -c '${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png'";
        # "${mod}+Shift+x" = "exec sh -c '${pkgs.i3lock}/bin/i3lock -c 222222 & sleep 5 && xset dpms force of'";

        # Focus
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        # Move
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";


        # Split
        "${mod}+b" = "split h";
        

        # My multi monitor setup
        "${mod}+m" = "move workspace to output DP-4";
        "${mod}+Shift+m" = "move workspace to output DP-0";

        # Lock
        "${mod}+x" = "exec i3lock";

        # Media Keys
        "XF86AudioPlay" = "exec playerctl -p spotify play-pause";
        "XF86AudioNext" = "exec playerctl -p spotify next";
        "XF86AudioPrev" = "exec playerctl -p spotify previous";


       # Adjust Gaps
       "${mod}+s" = "gaps inner current plus 10";
       "${mod}+Shift+s" = "gaps inner current minus 10";
       
      };

      modes.resize =  {
        "h" = "resize shrink width 10 px or 10 ppt";
        "j" = "resize grow height 10 px or 10 ppt";
        "k" = "resize shrink height 10 px or 10 ppt";
        "l" = "resize grow width 10 px or 10 ppt";
        "Escape" = "mode default";
      };

    
    };
    extraConfig = ''
      for_window [class="^.*"] border pixel 3
    '';
  };
}
