{ config, lib, ... }:
let cfg = config.netscape.system.desktop; in
lib.mkIf cfg.sway.enable {
  programs.sway.enable = true;
}
