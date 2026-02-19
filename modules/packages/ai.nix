{ config, lib, pkgs, claude-desktop, ... }:

let
  cfg = config.netscape.packages.ai;
in
{
  options.netscape.packages.ai = {
    enable = lib.mkEnableOption "AI Packages" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.netscape = {
      home.packages = [
        pkgs.unstable.opencode
        pkgs.unstable.claude-code
        claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs
        pkgs.beads
        pkgs.gastown
      ];
    };
  };
}
