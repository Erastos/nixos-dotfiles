{ config, lib, pkgs, home-manager, ...}:

let
  colors = config.colors;
in
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        "river/mode" = {
          format = "mode: {}";
        };
        modules-left = ["river/tags" "river/mode"];
        modules-center = ["river/window"];
        modules-right = ["clock"];
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: Hack Nerd Font;
      }
      window#waybar {
        background: #${colors.background};
        color: #${colors.foreground};
      }
      #tags button {
        padding: 0 5px;
        color: #${colors.foreground};
      }
      #tags button.focused {
        background: #${colors.background};
        background: linear-gradient(0deg, #${colors.background} 0%, #${colors.red} 75%, #${colors.magenta} 100%);
      }
      #tags button.occupied {
        border-top: 2px solid #${colors.brightRed};
      }
      #mode {
        padding-left: 50px;
        padding-right: 50px;
      }
      #clock {
        color: #${colors.foreground};
        padding-right: 5px;
      }
    '';
  };
}
