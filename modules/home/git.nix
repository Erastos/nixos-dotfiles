{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.git;
in
{
  options.netscape.home.git = {
    enable = lib.mkEnableOption "Git configuration" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = { user = { name = "Andrew Smith"; email = "andrew@andrewnsmith.net"; }; };
    };

    programs.gh.enable = true;
  };
}
