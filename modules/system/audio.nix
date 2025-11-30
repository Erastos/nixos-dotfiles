{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.audio;
in
{
  options.netscape.system.audio = {
    enable = lib.mkEnableOption "PipeWire audio" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
