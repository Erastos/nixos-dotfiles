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
      type = lib.types.enum [ "burgundy-red" "blue-matrix" "cyberpunk-neon" "enterprise-2000" "enterprise-2000-dark" ];
      default = "burgundy-red";
      description = ''
        Global colorscheme to use across all themed applications.
        Available schemes:
        - burgundy-red: Dark burgundy/red aesthetic (original)
        - blue-matrix: Bright cyan/blue matrix-inspired theme
        - cyberpunk-neon: Vibrant cyberpunk neon theme with pinks and cyans
        - enterprise-2000: Red Hat Bluecurve early-2000s corporate look (light)
        - enterprise-2000-dark: Enterprise 2000 with navy dark surfaces (Tango accents)
      '';
    };
  };

  # Expose selected colorscheme as config.colors
  options.colors = lib.mkOption {
    type = lib.types.attrs;
    default = selectedScheme;
    description = "Currently active color scheme";
  };

}
