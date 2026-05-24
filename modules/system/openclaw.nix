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
      key = "${config.networking.hostName}/openclaw/discord_token";
      mode = "0400";
      owner = "netscape";
      group = "users";
    };
    sops.secrets."openclaw-anthropic-key" = {
      sopsFile = ../../secrets/secrets.yaml;
      key = "${config.networking.hostName}/openclaw/anthropic_api_key";
      mode = "0400";
      owner = "netscape";
      group = "users";
    };
    sops.secrets."openclaw-gateway-token" = {
      sopsFile = ../../secrets/secrets.yaml;
      key = "${config.networking.hostName}/openclaw/gateway_token";
      mode = "0400";
      owner = "netscape";
      group = "users";
    };
  };
}
