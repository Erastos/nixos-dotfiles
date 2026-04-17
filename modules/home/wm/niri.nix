{ ... }:
{
  homeModuleLib.niri = { config, lib, pkgs, ... }:
  let
    colors = config.colors;
  in
  {
    home.packages = with pkgs; [
      swww
      swayidle
      grim
      slurp
      swappy
      cliphist
      wl-clipboard
      xfce.thunar
      xfce.thunar-volman
      xfce.thunar-archive-plugin
      blueman
      networkmanagerapplet
      pavucontrol
      playerctl
      pamixer
      papirus-icon-theme
      bibata-cursors
      libsForQt5.qtstyleplugin-kvantum
    ];

    xdg.configFile."niri/config.kdl".text = ''
      environment {
          GTK_THEME "${config.netscape.home.theming.gtkTheme}"
          QT_QPA_PLATFORMTHEME "kvantum"
      }

      input {
          keyboard {
              xkb { layout "us" }
              repeat-delay 300
              repeat-rate 50
          }
          touchpad {
              tap
              natural-scroll
              accel-speed 0.2
          }
          mouse { accel-speed 0.0 }
      }

      output "DP-1" {
          mode "2560x1440@165"
          position x=0 y=0
      }

      layout {
          gaps 16
          center-focused-column "never"
          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }
          default-column-width { proportion 0.5; }
          focus-ring {
              width 2
              active-color "#${colors.red}"
              inactive-color "#${colors.brightBlack}"
          }
          border { off }
          struts { left 0; right 0; top 0; bottom 0 }
      }

      spawn-at-startup "waybar"
      spawn-at-startup "swww-daemon"
      spawn-at-startup "swww" "img" "/home/netscape/Pictures/wallpaper.jpg"
      spawn-at-startup "dunst"
      spawn-at-startup "nm-applet" "--indicator"
      spawn-at-startup "blueman-applet"
      spawn-at-startup "wl-paste" "--watch" "cliphist" "store"

      prefer-no-csd
      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      animations {
          slowdown 0.8
          workspace-switch { spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001 }
          window-open { duration-ms 150; curve "ease-out-expo" }
          window-close { duration-ms 150; curve "ease-out-quad" }
          horizontal-view-movement { spring damping-ratio=1.0 stiffness=800 epsilon=0.0001 }
          window-movement { spring damping-ratio=1.0 stiffness=800 epsilon=0.0001 }
          window-resize { spring damping-ratio=1.0 stiffness=800 epsilon=0.0001 }
          config-notification-open-close { spring damping-ratio=0.6 stiffness=1000 epsilon=0.001 }
      }

      window-rule {
          match is-focused=false
          opacity 0.9
      }
      window-rule {
          match app-id=r#"^org\.gnome\."#
          default-column-width { proportion 0.5; }
      }
      window-rule {
          match app-id="pavucontrol"
          default-column-width { fixed 800; }
      }
      window-rule {
          match app-id="nm-connection-editor"
          default-column-width { fixed 600; }
      }
      window-rule {
          match app-id="blueman-manager"
          default-column-width { fixed 600; }
      }
      window-rule {
          match title="File Operation Progress"
          open-floating true
      }

      binds {
          Mod+Return { spawn "foot"; }
          Mod+D { spawn "rofi" "-show" "drun" "-show-icons"; }
          Mod+E { spawn "thunar"; }
          Mod+W { spawn "firefox"; }
          Mod+V { spawn "bash" "-c" "cliphist list | rofi -dmenu | cliphist decode | wl-copy"; }

          Mod+Q { close-window; }

          Mod+H { focus-column-left; }
          Mod+L { focus-column-right; }
          Mod+J { focus-window-down; }
          Mod+K { focus-window-up; }
          Mod+Left { focus-column-left; }
          Mod+Right { focus-column-right; }
          Mod+Down { focus-window-down; }
          Mod+Up { focus-window-up; }

          Mod+Shift+H { move-column-left; }
          Mod+Shift+L { move-column-right; }
          Mod+Shift+J { move-window-down; }
          Mod+Shift+K { move-window-up; }
          Mod+Shift+Left { move-column-left; }
          Mod+Shift+Right { move-column-right; }
          Mod+Shift+Down { move-window-down; }
          Mod+Shift+Up { move-window-up; }

          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }

          Mod+Shift+1 { move-column-to-workspace 1; }
          Mod+Shift+2 { move-column-to-workspace 2; }
          Mod+Shift+3 { move-column-to-workspace 3; }
          Mod+Shift+4 { move-column-to-workspace 4; }
          Mod+Shift+5 { move-column-to-workspace 5; }
          Mod+Shift+6 { move-column-to-workspace 6; }
          Mod+Shift+7 { move-column-to-workspace 7; }
          Mod+Shift+8 { move-column-to-workspace 8; }
          Mod+Shift+9 { move-column-to-workspace 9; }

          Mod+R { switch-preset-column-width; }
          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }
          Mod+C { center-column; }

          Mod+BracketLeft { consume-window-into-column; }
          Mod+BracketRight { expel-window-from-column; }

          Mod+Comma { focus-monitor-left; }
          Mod+Period { focus-monitor-right; }
          Mod+Shift+Comma { move-column-to-monitor-left; }
          Mod+Shift+Period { move-column-to-monitor-right; }

          Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
          Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
          Mod+Page_Down { focus-workspace-down; }
          Mod+Page_Up { focus-workspace-up; }
          Mod+Shift+Page_Down { move-column-to-workspace-down; }
          Mod+Shift+Page_Up { move-column-to-workspace-up; }

          Mod+Home { focus-column-first; }
          Mod+End { focus-column-last; }
          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }
          Mod+Space { toggle-window-floating; }

          Print { screenshot; }
          Ctrl+Print { screenshot-screen; }
          Alt+Print { screenshot-window; }

          Ctrl+Alt+L { spawn "swaylock"; }
          Mod+Shift+E { spawn "rofi" "-show" "power-menu" "-modi" "power-menu:rofi-power-menu"; }
          Mod+Shift+Escape { quit; }

          XF86AudioRaiseVolume allow-when-locked=true { spawn "pamixer" "-i" "5"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn "pamixer" "-d" "5"; }
          XF86AudioMute allow-when-locked=true { spawn "pamixer" "-t"; }
          XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
          XF86AudioNext allow-when-locked=true { spawn "playerctl" "next"; }
          XF86AudioPrev allow-when-locked=true { spawn "playerctl" "previous"; }
          XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "set" "+5%"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }
      }
    '';

    home.file.".local/bin/screenshot" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
        mkdir -p "$SCREENSHOTS_DIR"
        case "''${1:-area}" in
          area)   grim -g "$(slurp)" - | swappy -f - ;;
          window) grim -g "$(slurp)" - | swappy -f - ;;
          screen) grim - | swappy -f - ;;
          *) echo "Usage: screenshot [area|window|screen]"; exit 1 ;;
        esac
      '';
    };
  };
}
