{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.wm;
  colors = config.colors;
  enterprise = cfg.niri.profile == "enterprise-2000";

  # Profile-dependent niri config fragments. Nix indented strings strip the
  # common leading whitespace of their lines, so fragments written at a
  # 4-space base render flush-left in the generated config; single-line binds
  # interpolate at the outer line's remaining indentation.
  layoutSection = if enterprise then ''
    layout {
        gaps 4
        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        focus-ring {
            off
        }

        border {
            width 1
            active-color "#4464ac"
            inactive-color "#777777"
        }

        struts {
            left 0
            right 0
            top 0
            bottom 0
        }
    }
  '' else ''
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

        border {
            off
        }

        struts {
            left 0
            right 0
            top 0
            bottom 0
        }
    }
  '';

  startupSection = if enterprise then ''
    spawn-at-startup "noctalia"
  '' else ''
    spawn-at-startup "waybar"
    spawn-at-startup "awww-daemon"
    spawn-at-startup "awww" "img" "/home/netscape/Pictures/wallpaper.jpg"
    spawn-at-startup "dunst"
    spawn-at-startup "nm-applet" "--indicator"
    spawn-at-startup "blueman-applet"
    spawn-at-startup "wl-paste" "--watch" "cliphist" "store"
  '';

  animationsSection = if enterprise then ''
    animations {
        slowdown 1.0

        workspace-switch {
            spring damping-ratio=1.0 stiffness=1500 epsilon=0.0001
        }

        window-open {
            duration-ms 100
            curve "ease-out-expo"
        }

        window-close {
            duration-ms 100
            curve "ease-out-quad"
        }

        horizontal-view-movement {
            spring damping-ratio=1.0 stiffness=1500 epsilon=0.0001
        }

        window-movement {
            spring damping-ratio=1.0 stiffness=1500 epsilon=0.0001
        }

        window-resize {
            spring damping-ratio=1.0 stiffness=1500 epsilon=0.0001
        }

        config-notification-open-close {
            spring damping-ratio=1.0 stiffness=1500 epsilon=0.001
        }
    }
  '' else ''
    animations {
        slowdown 0.8

        workspace-switch {
            spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
        }

        window-open {
            duration-ms 150
            curve "ease-out-expo"
        }

        window-close {
            duration-ms 150
            curve "ease-out-quad"
        }

        horizontal-view-movement {
            spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
        }

        window-movement {
            spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
        }

        window-resize {
            spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
        }

        config-notification-open-close {
            spring damping-ratio=0.6 stiffness=1000 epsilon=0.001
        }
    }
  '';

  # Translucent unfocused windows are a modern-rice look; the enterprise
  # profile keeps windows opaque.
  opacityRule = lib.optionalString (!enterprise) ''
    window-rule {
        match is-focused=false
        opacity 0.9
    }
  '';

  bindLauncher = if enterprise
    then ''Mod+D { spawn "noctalia" "msg" "panel-toggle" "launcher"; }''
    else ''Mod+D { spawn "rofi" "-show" "drun" "-show-icons"; }'';
  bindClipboard = if enterprise
    then ''Mod+V { spawn "noctalia" "msg" "panel-toggle" "clipboard"; }''
    else ''Mod+V { spawn "bash" "-c" "cliphist list | rofi -dmenu | cliphist decode | wl-copy"; }'';
  bindLock = if enterprise
    then ''Ctrl+Alt+L { spawn "noctalia" "msg" "session" "lock"; }''
    else ''Ctrl+Alt+L { spawn "swaylock"; }'';
  bindPower = if enterprise
    then ''Mod+Shift+E { spawn "noctalia" "msg" "panel-toggle" "session"; }''
    else ''Mod+Shift+E { spawn "rofi" "-show" "power-menu" "-modi" "power-menu:rofi-power-menu"; }'';
  bindVolUp = if enterprise
    then ''XF86AudioRaiseVolume allow-when-locked=true { spawn "noctalia" "msg" "volume-up"; }''
    else ''XF86AudioRaiseVolume allow-when-locked=true { spawn "pamixer" "-i" "5"; }'';
  bindVolDown = if enterprise
    then ''XF86AudioLowerVolume allow-when-locked=true { spawn "noctalia" "msg" "volume-down"; }''
    else ''XF86AudioLowerVolume allow-when-locked=true { spawn "pamixer" "-d" "5"; }'';
  bindMute = if enterprise
    then ''XF86AudioMute allow-when-locked=true { spawn "noctalia" "msg" "volume-mute"; }''
    else ''XF86AudioMute allow-when-locked=true { spawn "pamixer" "-t"; }'';
  bindBrightUp = if enterprise
    then ''XF86MonBrightnessUp allow-when-locked=true { spawn "noctalia" "msg" "brightness-up"; }''
    else ''XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "set" "+5%"; }'';
  bindBrightDown = if enterprise
    then ''XF86MonBrightnessDown allow-when-locked=true { spawn "noctalia" "msg" "brightness-down"; }''
    else ''XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }'';

  niriConfig = ''
    // Environment variables for spawned processes
    environment {
        GTK_THEME "${config.netscape.home.theming.gtkTheme}"
        QT_QPA_PLATFORMTHEME "kvantum"
    }

    // Input configuration
    input {
        keyboard {
            xkb {
                layout "us"
            }
            repeat-delay 300
            repeat-rate 50
        }

        touchpad {
            tap
            natural-scroll
            accel-speed 0.2
        }

        mouse {
            accel-speed 0.0
        }
    }

    // Output configuration
    output "DP-2" {
        mode "2560x1440@144.003"
        position x=0 y=0
    }

    // Layout configuration
    ${layoutSection}

    // Spawn startup programs
    ${startupSection}

    // Prefer server-side decorations
    prefer-no-csd

    // Screenshot path
    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    // Animation settings
    ${animationsSection}

    // Window rules
    ${opacityRule}
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

    // Keybindings
    binds {
        // Programs
        Mod+Return { spawn "foot"; }
        ${bindLauncher}
        Mod+E { spawn "thunar"; }
        Mod+W { spawn "firefox"; }
        ${bindClipboard}

        // Window management
        Mod+Q { close-window; }

        // Focus
        Mod+H { focus-column-left; }
        Mod+L { focus-column-right; }
        Mod+J { focus-window-down; }
        Mod+K { focus-window-up; }

        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Down { focus-window-down; }
        Mod+Up { focus-window-up; }

        // Move windows
        Mod+Shift+H { move-column-left; }
        Mod+Shift+L { move-column-right; }
        Mod+Shift+J { move-window-down; }
        Mod+Shift+K { move-window-up; }

        Mod+Shift+Left { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Down { move-window-down; }
        Mod+Shift+Up { move-window-up; }

        // Workspaces
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

        // Column sizing
        Mod+R { switch-preset-column-width; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+C { center-column; }

        // Consume/expel windows
        Mod+BracketLeft { consume-window-into-column; }
        Mod+BracketRight { expel-window-from-column; }

        // Monitor focus and movement
        Mod+Comma { focus-monitor-left; }
        Mod+Period { focus-monitor-right; }
        Mod+Shift+Comma { move-column-to-monitor-left; }
        Mod+Shift+Period { move-column-to-monitor-right; }

        // Workspace scrolling with mouse wheel
        Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }

        // Previous/next workspace
        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up { focus-workspace-up; }
        Mod+Shift+Page_Down { move-column-to-workspace-down; }
        Mod+Shift+Page_Up { move-column-to-workspace-up; }

        // Focus first/last column
        Mod+Home { focus-column-first; }
        Mod+End { focus-column-last; }

        // Adjust column width
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        // Float
        Mod+Space { toggle-window-floating; }

        // Screenshots
        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        // Lock screen
        ${bindLock}

        // Power menu
        ${bindPower}

        // Exit niri
        Mod+Shift+Escape { quit; }

        // Volume controls
        ${bindVolUp}
        ${bindVolDown}
        ${bindMute}

        // Media controls
        XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
        XF86AudioNext allow-when-locked=true { spawn "playerctl" "next"; }
        XF86AudioPrev allow-when-locked=true { spawn "playerctl" "previous"; }

        // Brightness controls
        ${bindBrightUp}
        ${bindBrightDown}
    }
  '';
in
{
  config = lib.mkIf cfg.niri.enable (lib.mkMerge [
    {
      # Auto-enable related modules when niri is enabled. In the enterprise
      # profile the Noctalia shell provides bar/launcher/notifications/lock,
      # so the legacy daemons stay off (dunst would fight Noctalia's
      # notification daemon for the same DBus name).
      netscape.home.wm.waybar.enable = lib.mkDefault (!enterprise);
      netscape.home.wm.rofi.enable = lib.mkDefault (!enterprise);
      netscape.home.wm.dunst.enable = lib.mkDefault (!enterprise);
      netscape.home.wm.swaylock.enable = lib.mkDefault (!enterprise);

      home.packages = with pkgs; [
        awww
        swayidle
        grim
        slurp
        swappy
        cliphist
        wl-clipboard
        thunar
        thunar-volman
        thunar-archive-plugin
        blueman
        networkmanagerapplet
        pavucontrol
        playerctl
        pamixer
        papirus-icon-theme
        bibata-cursors
        libsForQt5.qtstyleplugin-kvantum
      ];

      # niri config
      xdg.configFile."niri/config.kdl".text = niriConfig;

      # Screenshot helper script
      home.file.".local/bin/screenshot" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          # Screenshot helper for niri

          SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
          mkdir -p "$SCREENSHOTS_DIR"

          case "''${1:-area}" in
            area)
              grim -g "$(slurp)" - | swappy -f -
              ;;
            window)
              # niri doesn't have easy window geometry query yet, use area
              grim -g "$(slurp)" - | swappy -f -
              ;;
            screen)
              grim - | swappy -f -
              ;;
            *)
              echo "Usage: screenshot [area|window|screen]"
              exit 1
              ;;
          esac
        '';
      };
    }

    (lib.mkIf enterprise {
      # Early-2000s Red Hat Bluecurve session: Noctalia shell, Bluecurve GTK
      # theme and icons, Luxi Sans everywhere, square corners, solid panels.
      netscape.home.theming.gtkTheme = lib.mkDefault "Bluecurve-Dark";
      gtk.enable = lib.mkDefault true;
      gtk.iconTheme = {
        name = "Bluecurve";
        package = pkgs.bluecurve;
      };

      home.packages = [ pkgs.unstable.noctalia ];

      # Noctalia shell configuration (TOML, hot-reloaded at ~/.config/noctalia/)
      xdg.configFile."noctalia/config.toml".text = ''
        # Noctalia shell — Trinity "Enterprise 2000" (Red Hat Bluecurve) profile
        [theme]
        mode = "dark"
        source = "custom"
        custom_palette = "Bluecurve"

        [shell]
        corner_radius_scale = 0.0
        font_family = "Luxi Sans"
        time_format = "{:%H:%M}"
        date_format = "%A, %d %B %Y"
        # Fresh hosts must not run the setup wizard: it writes [theme]
        # mode/source/wallpaper_scheme overrides to settings.toml that
        # clobber the declarative Bluecurve theme below.
        setup_wizard_enabled = false

        [shell.animation]
        enabled = false

        [shell.panel]
        transparency_mode = "solid"
        borders = true
        shadow = false

        [wallpaper]
        enabled = true
        fill_mode = "crop"
        transition_duration = 0
        transition_on_startup = false

        # wallpaper: wallhaven.cc/w/d6lmv3 by Cyb3rCr0w (personal-use, no explicit license)
        # source: ~/Dropbox/Pictures/enterprise-vaporwave.jpg (plain path, read live by Noctalia — not store-instantiated)
        [wallpaper.default]
        path = "/home/netscape/Dropbox/Pictures/enterprise-vaporwave.jpg"

        [bar.main]
        position = "top"
        thickness = 28
        background_opacity = 1.0
        radius = 0.0
        margin_ends = 0
        margin_edge = 0
        padding = 8
        widget_spacing = 12
        shadow = false
        capsule = false
        start  = ["launcher", "workspaces"]
        center = ["clock"]
        end    = ["tray", "notifications", "network", "volume", "control-center", "session"]

        [notification]
        background_opacity = 1.0

        [osd]
        position = "bottom_center"
        background_opacity = 1.0

        [lockscreen]
        enabled = true
      '';

      # Noctalia palette — Bluecurve dark (the active mode) plus a light
      # fallback in case the mode is ever toggled in Noctalia's GUI.
      xdg.configFile."noctalia/palettes/Bluecurve.json".text = builtins.toJSON {
        light = {
          mPrimary = "#4464ac"; mOnPrimary = "#ffffff";
          mSecondary = "#5e7ab7"; mOnSecondary = "#ffffff";
          mTertiary = "#f57900"; mOnTertiary = "#ffffff";
          mError = "#cc0000"; mOnError = "#ffffff";
          mSurface = "#e6e6e6"; mOnSurface = "#000000";
          mSurfaceVariant = "#cccccc"; mOnSurfaceVariant = "#333333";
          mOutline = "#777777"; mShadow = "#000000";
          mHover = "#f5f5f5"; mOnHover = "#000000";
          terminal = {
            background = "#ffffff"; foreground = "#000000";
            cursor = "#4464ac"; cursorText = "#ffffff";
            selectionBg = "#4464ac"; selectionFg = "#ffffff";
            normal = { black = "#2e3436"; red = "#cc0000"; green = "#4e9a06"; yellow = "#c4a000"; blue = "#4464ac"; magenta = "#75507b"; cyan = "#06989a"; white = "#d3d7cf"; };
            bright  = { black = "#555753"; red = "#ef2929"; green = "#73d216"; yellow = "#f57900"; blue = "#5e7ab7"; magenta = "#ad7fa8"; cyan = "#34e2e2"; white = "#eeeeec"; };
          };
        };
        dark = {
          mPrimary = "#5e7ab7"; mOnPrimary = "#ffffff";
          mSecondary = "#4464ac"; mOnSecondary = "#ffffff";
          mTertiary = "#f57900"; mOnTertiary = "#ffffff";
          mError = "#cc0000"; mOnError = "#ffffff";
          mSurface = "#1f2a3d"; mOnSurface = "#ffffff";
          mSurfaceVariant = "#2e3d5c"; mOnSurfaceVariant = "#d3d7cf";
          mOutline = "#777777"; mShadow = "#000000";
          mHover = "#374b6e"; mOnHover = "#ffffff";
          terminal = {
            background = "#1f2a3d"; foreground = "#ffffff";
            cursor = "#ffffff"; cursorText = "#1f2a3d";
            selectionBg = "#4464ac"; selectionFg = "#ffffff";
            normal = { black = "#2e3436"; red = "#cc0000"; green = "#4e9a06"; yellow = "#c4a000"; blue = "#5e7ab7"; magenta = "#75507b"; cyan = "#06989a"; white = "#d3d7cf"; };
            bright  = { black = "#555753"; red = "#ef2929"; green = "#73d216"; yellow = "#f57900"; blue = "#7a9ede"; magenta = "#ad7fa8"; cyan = "#34e2e2"; white = "#ffffff"; };
          };
        };
      };
    })
  ]);
}
