{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.git;
in
{
  options.netscape.home.git = {
    enable = lib.mkEnableOption "Git configuration" // { default = true; };
    userName = lib.mkOption {
      type = lib.types.str;
      default = "Andrew Smith";
      description = "Git user name";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "andrew@andrewnsmith.net";
      description = "Git user email";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
      };
    };

    programs.gh.enable = true;
  };
}
