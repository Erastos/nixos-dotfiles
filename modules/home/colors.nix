{ ... }:
{
  homeModuleLib.colors = { config, lib, ... }:
  let
    cfg = config.netscape.home.colors;
    colorschemes = import ./_colorschemes { inherit lib; };
    selectedScheme = colorschemes.${cfg.scheme};
  in
  {
    options.netscape.home.colors.scheme = lib.mkOption {
      type = lib.types.enum [ "burgundy-red" "blue-matrix" "cyberpunk-neon" ];
      default = "burgundy-red";
      description = "Global color scheme for all themed applications";
    };

    options.colors = lib.mkOption {
      type = lib.types.attrs;
      default = selectedScheme;
      description = "Currently active color scheme";
    };
  };
}
