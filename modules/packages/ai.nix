{ config, lib, pkgs, unstable, claude-desktop, ... }:

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
        claude-desktop.packages.${stdenv.hostPlatform.system}.claude-desktop-with-fhs
        beads
        gastown
      ];
    };
  };
}
