{ config, lib, pkgs, unstable, home-manager, ...}:
# # Red Terminal Color Scheme
# colors:
#   primary:
#     background: '#1B0C0C'
#     foreground: '#E6CFCF'
#   cursor:
#     text: '#1B0C0C'
#     cursor: '#FF3B3B'
#   selection:
#     text: '#E6CFCF'
#     background: '#3A1B1B'
#
#   normal:
#     black:   '#120707'
#     red:     '#E03131'
#     green:   '#5E4E4E'
#     yellow:  '#D97A3D'
#     blue:    '#4B3E4B'
#     magenta: '#B13664'
#     cyan:    '#4D7070'
#     white:   '#E3D9D9'
#
#   bright:
#     black:   '#2A1414'
#     red:     '#FF4040'
#     green:   '#887272'
#     yellow:  '#FF9E57'
#     blue:    '#7A627A'
#     magenta: '#D74B8A'
#     cyan:    '#7A9E9E'
#     white:   '#FFF2F2'
#
#   # Optional accents (for supporting terminals)
#   accents:
#     border: '#802020'
#     inactive_tab: '#2A1717'
#     active_tab: '#C22E2E'
#     error: '#FF4B4B'
#     warning: '#E68B42'
#     success: '#A67474'

let
  colors = config.colors;
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Hack Nerd Font:size=12";
      };
      cursor = {
        color = "${colors.cursor.text} ${colors.cursor.cursor}"; # <text> <cursor>
      };
      colors = {
        foreground = colors.foreground;
        background = colors.background;
        regular0 = colors.black; # black
        regular1 = colors.red; # red
        regular2 = colors.green; # green
        regular3 = colors.yellow; # yellow
        regular4 = colors.blue; # blue
        regular5 = colors.magenta; # magenta
        regular6 = colors.cyan; # cyan
        regular7 = colors.white; # white
        bright0 = colors.brightBlack; # bright black
        bright1 = colors.brightRed; # bright red
        bright2 = colors.brightGreen; # bright green
        bright3 = colors.brightYellow; # bright yellow
        bright4 = colors.brightBlue; # bright blue
        bright5 = colors.brightMagenta; # bright magenta
        bright6 = colors.brightCyan; # bright cyan
        bright7 = colors.brightWhite; # bright white
      };
    };
  };
}

