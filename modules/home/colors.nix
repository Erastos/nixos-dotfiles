{ config, lib, osConfig, ... }:

let
  cfg = config.netscape.home.colors;
  isLaptop = osConfig.netscape.hostType == "laptop";

  # Import all colorscheme definitions
  colorschemes = import ./colorschemes { inherit lib; };

  # Get selected colorscheme
  selectedScheme = colorschemes.${cfg.scheme};
in
{
  options.netscape.home.colors = {
    enable = lib.mkEnableOption "color scheme configuration" // { default = isLaptop; };

    scheme = lib.mkOption {
      type = lib.types.enum [ "burgundy-red" "blue-matrix" ];
      default = "burgundy-red";
      description = ''
        Global colorscheme to use across all themed applications.
        Available schemes:
        - burgundy-red: Dark burgundy/red aesthetic (original)
        - blue-matrix: Bright cyan/blue matrix-inspired theme
      '';
    };
  };

  # Expose selected colorscheme as config.colors
  options.colors = lib.mkOption {
    type = lib.types.attrs;
    default = selectedScheme;
    description = "Currently active color scheme";
  };

  config = lib.mkIf cfg.enable { };
}
