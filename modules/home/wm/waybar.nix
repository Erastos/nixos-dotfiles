{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.wm;
  colors = config.colors;
in
{
  config = lib.mkIf cfg.waybar.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = lib.mkMerge [
          # Common settings
          {
            layer = "top";
            position = "top";
            height = 30;
            margin-top = 4;
            margin-left = 8;
            margin-right = 8;
            modules-center = [ "clock" ];
            modules-right = [ "tray" "pulseaudio" "network" "bluetooth" "cpu" "memory" "custom/power" ];

            clock = {
              format = "{:%H:%M}";
              format-alt = "{:%A, %B %d, %Y}";
              tooltip-format = "<tt><small>{calendar}</small></tt>";
            };

            cpu = {
              format = " {usage}%";
              tooltip = true;
            };

            memory = {
              format = " {}%";
            };

            pulseaudio = {
              format = "{icon} {volume}%";
              format-muted = " Muted";
              format-icons = {
                default = [ "" "" "" ];
              };
              on-click = "pavucontrol";
            };

            network = {
              format-wifi = " {signalStrength}%";
              format-ethernet = " {ipaddr}";
              format-disconnected = "󰖪 Disconnected";
              tooltip-format = "{essid} ({signalStrength}%)";
              on-click = "nm-connection-editor";
            };

            bluetooth = {
              format = "";
              format-disabled = "󰂲";
              format-connected = " {num_connections}";
              tooltip-format = "{device_alias}";
              on-click = "blueman-manager";
            };

            tray = {
              icon-size = 16;
              spacing = 8;
            };

            "custom/power" = {
              format = "⏻";
              tooltip = false;
              on-click = "rofi -show power-menu -modi power-menu:rofi-power-menu";
            };
          }

          # niri-specific modules
          (lib.mkIf cfg.niri.enable {
            modules-left = [ "niri/workspaces" "niri/window" ];

            "niri/workspaces" = {
              # format = "{icon}";
              # format-icons = {
              #   active = "";
              #   default = "";
              # };
            };

            "niri/window" = {
              format = "{}";
              max-length = 50;
            };
          })

          # river-specific modules
          (lib.mkIf cfg.river.enable {
            modules-left = [ "river/tags" "river/mode" ];

            "river/tags" = { };

            "river/mode" = {
              format = "mode: {}";
            };
          })
        ];
      };

      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: Hack Nerd Font;
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background: #${colors.background};
          color: #${colors.foreground};
          border-radius: 8px;
          border: 1px solid #${colors.magenta};
        }

        #workspaces button {
          padding: 0 8px;
          color: #${colors.foreground};
          background: transparent;
          border-radius: 4px;
          margin: 2px;
        }

        #workspaces button.active,
        #workspaces button.focused {
          background: linear-gradient(135deg, #${colors.magenta} 0%, #${colors.cyan} 100%);
          color: #${colors.background};
          box-shadow: 0 0 8px #${colors.magenta};
        }

        #workspaces button:hover {
          background: #${colors.brightBlack};
        }

        #tags button {
          padding: 0 5px;
          color: #${colors.foreground};
        }

        #tags button.focused {
          background: linear-gradient(0deg, #${colors.background} 0%, #${colors.red} 75%, #${colors.magenta} 100%);
        }

        #tags button.occupied {
          border-top: 2px solid #${colors.brightRed};
        }

        #window {
          padding: 0 10px;
          color: #${colors.cyan};
        }

        #clock {
          padding: 0 10px;
          color: #${colors.foreground};
          font-weight: bold;
        }

        #cpu,
        #memory,
        #pulseaudio,
        #network,
        #bluetooth,
        #tray {
          padding: 0 10px;
        }

        #cpu {
          color: #${colors.cyan};
        }

        #memory {
          color: #${colors.magenta};
        }

        #pulseaudio {
          color: #${colors.green};
        }

        #network {
          color: #${colors.blue};
        }

        #bluetooth {
          color: #${colors.cyan};
        }

        #custom-power {
          padding: 0 12px;
          color: #${colors.red};
        }

        #custom-power:hover {
          color: #${colors.brightRed};
        }

        tooltip {
          background: #${colors.background};
          border: 1px solid #${colors.magenta};
          border-radius: 8px;
        }
      '';
    };
  };
}
