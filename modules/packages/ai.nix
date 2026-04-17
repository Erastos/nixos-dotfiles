{ config, lib, pkgs, claude-desktop, hermes-agent, ... }:

let
  cfg = config.netscape.packages.ai;
in
{
  options.netscape.packages.ai = {
    enable = lib.mkEnableOption "AI Packages" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    services.hermes-agent = {
      enable = true;
      settings.model.default = "anthropic/claude-sonnet-4";
      addToSystemPackages = true;
    };
    home-manager.users.netscape = {
      home.packages = [
        pkgs.unstable.opencode
        pkgs.unstable.claude-code
        claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs
        pkgs.beads
        pkgs.gastown
        pkgs.unstable.openclaw
      ];
    };
  };
}
