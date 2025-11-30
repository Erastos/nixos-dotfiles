{ config, lib, pkgs, unstable, ... }:

let
  cfg = config.netscape.packages.ai;
in
{
  options.netscape.packages.ai = {
    enable = lib.mkEnableOption "AI Packages" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.netscape = {
      home.packages = with unstable; [
        opencode
        claude-code
      ];
    };
  };
}
