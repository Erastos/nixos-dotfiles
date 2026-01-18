{ config, lib, osConfig, ... }:

let
  cfg = config.netscape.home.colors;

  # Import all colorscheme definitions
  colorschemes = import ./colorschemes { inherit lib; };

  # Get selected colorscheme
  selectedScheme = colorschemes.${cfg.scheme};
in
{
  options.netscape.home.colors = {
    enable = lib.mkEnableOption "color scheme configuration";

    scheme = lib.mkOption {
      type = lib.types.enum [ "burgundy-red" "blue-matrix" "cyberpunk-neon" ];
      default = "burgundy-red";
      description = ''
        Global colorscheme to use across all themed applications.
        Available schemes:
        - burgundy-red: Dark burgundy/red aesthetic (original)
        - blue-matrix: Bright cyan/blue matrix-inspired theme
        - cyberpunk-neon: Vibrant cyberpunk neon theme with pinks and cyans
      '';
    };
  };

  # Expose selected colorscheme as config.colors
  options.colors = lib.mkOption {
    type = lib.types.attrs;
    default = selectedScheme;
    description = "Currently active color scheme";
  };

  config = {
    # Enable colors by default on laptops
    netscape.home.colors.enable = lib.mkDefault (osConfig.netscape.hostType == "laptop");
  };
}
