{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.home.openclaw;
  discordCfg = cfg.discord;
in
{
  options.netscape.home.openclaw = {
    enable = lib.mkEnableOption "OpenClaw AI assistant gateway";

    discord = {
      enable = lib.mkEnableOption "OpenClaw Discord integration";

      accountName = lib.mkOption {
        type = lib.types.str;
        default = "default";
        description = "Name for the Discord account configuration";
      };

      allowedUsers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of Discord user IDs allowed to interact with the bot";
      };
    };

    documents = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to OpenClaw documents directory (AGENTS.md, SOUL.md, etc.)";
    };

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "List of OpenClaw plugins to install";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.openclaw = {
        enable = true;
        config.gateway.mode = "local";
      };
    }

    (lib.mkIf discordCfg.enable {
      programs.openclaw.config.secrets.providers.discord = {
        source = "env";
        allowlist = [ "OPENCLAW_DISCORD_TOKEN" ];
      };

      programs.openclaw.config.channels.discord.accounts.${discordCfg.accountName} = {
        enabled = true;
        # Ideally source = "file" pointing at the sops secret directly, but
        # upstream's generated oneOf type uses three structurally-identical
        # submodules differentiated only by the source enum value. The NixOS
        # module system's `either` picks the first variant whose `check`
        # passes (isAttrs), so it always commits to "env" and rejects "file".
        token = {
          source = "env";
          provider = "discord";
          id = "OPENCLAW_DISCORD_TOKEN";
        };
        allowFrom = discordCfg.allowedUsers;
        dmPolicy = "allowlist";
        groupPolicy = "disabled";
        actions = {
          messages = true;
          reactions = true;
        };
        commands.native = true;
      };

      # Load the Discord token from sops into the gateway service env
      systemd.user.services.openclaw-gateway = {
        Service = {
          ExecStartPre = [
            "${pkgs.writeShellScript "openclaw-load-discord-token" ''
              printf 'OPENCLAW_DISCORD_TOKEN=%s\n' \
                "$(cat /run/secrets/openclaw-discord-token)" \
                > "$XDG_RUNTIME_DIR/openclaw-discord.env"
            ''}"
          ];
          EnvironmentFile = [ "%t/openclaw-discord.env" ];
        };
      };
    })

    (lib.mkIf (cfg.documents != null) {
      programs.openclaw.documents = cfg.documents;
    })

    (lib.mkIf (cfg.plugins != []) {
      programs.openclaw.instances.default = {
        enable = true;
        inherit (cfg) plugins;
      };
    })
  ]);
}
