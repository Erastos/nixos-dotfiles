{ lib, ... }:

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
  colors = {
    black = "120707";
    red = "e03131";
    green = "5e4e4e";
    yellow = "d97a3d";
    blue = "4b3e4b";
    magenta = "b13664";
    cyan = "4d7070";
    white = "e3d9d9";

    brightBlack = "2a1414";
    brightRed = "ff4040";
    brightGreen = "887272";
    brightYellow = "ff9e57";
    brightBlue = "7a627a";
    brightMagenta = "d74b8a";
    brightCyan = "7a9e9e";
    brightWhite = "fff2f2";

    foreground = "e6cfcf";
    background = "1b0c0c";

    cursor = {
      text = "1b0c0c";
      cursor = "ff3b3b";
    };
  };
in
{
  options = {
    colors = lib.mkOption {
      type = lib.types.attrs;
      default = colors;
      description = "Red Colors";
    };
  };

  config = { };
}
