{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.wm;
  colors = config.colors;
in
{
  config = lib.mkIf cfg.dunst.enable {
    home.packages = with pkgs; [
      libnotify
    ];

    services.dunst = {
      enable = true;
      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          width = 350;
          height = 300;
          origin = "top-right";
          offset = "10x50";
          scale = 0;
          notification_limit = 5;
          progress_bar = true;
          indicate_hidden = true;
          transparency = 10;
          separator_height = 2;
          padding = 12;
          horizontal_padding = 12;
          text_icon_padding = 0;
          frame_width = 2;
          frame_color = "#${colors.magenta}";
          separator_color = "frame";
          sort = true;
          font = "Hack Nerd Font 10";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "left";
          vertical_alignment = "center";
          show_age_threshold = 60;
          ellipsize = "middle";
          ignore_newline = false;
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = true;
          icon_position = "left";
          min_icon_size = 32;
          max_icon_size = 64;
          sticky_history = true;
          history_length = 20;
          always_run_script = true;
          corner_radius = 8;
          ignore_dbusclose = false;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
        };
        urgency_low = {
          background = "#${colors.background}";
          foreground = "#${colors.foreground}";
          frame_color = "#${colors.cyan}";
          timeout = 5;
        };
        urgency_normal = {
          background = "#${colors.background}";
          foreground = "#${colors.foreground}";
          frame_color = "#${colors.magenta}";
          timeout = 10;
        };
        urgency_critical = {
          background = "#${colors.background}";
          foreground = "#${colors.foreground}";
          frame_color = "#${colors.red}";
          timeout = 0;
        };
      };
    };
  };
}
