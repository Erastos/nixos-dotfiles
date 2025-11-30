{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.packages.hardware;
in
{
  options.netscape.packages.hardware = {
    enable = lib.mkEnableOption "hardware development tools" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.netscape = {
      home.packages = with pkgs; [
        # Hardware
        arduino-ide
        platformio
      ];
    };
  };
}
