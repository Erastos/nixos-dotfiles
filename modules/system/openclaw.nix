{ config, lib, ... }:

let
  cfg = config.netscape.system.openclaw;
in
{
  options.netscape.system.openclaw = {
    enable = lib.mkEnableOption "OpenClaw sops secrets management";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."openclaw-discord-token" = {
      sopsFile = ../../secrets/secrets.yaml;
      key = "${config.netscape.systemName}/openclaw/discord_token";
      mode = "0400";
      owner = "netscape";
      group = "users";
    };
  };
}
