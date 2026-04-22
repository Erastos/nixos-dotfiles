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
        config = {
          gateway.mode = "local";
          agents.defaults.model = "anthropic/claude-sonnet-4-6";
          secrets.providers.anthropic = {
            source = "env";
            allowlist = [ "ANTHROPIC_API_KEY" ];
          };
        };
      };
    }

    (lib.mkIf discordCfg.enable {
      programs.openclaw.config.secrets.providers.discord = {
        source = "env";
        allowlist = [ "OPENCLAW_DISCORD_TOKEN" ];
      };

      programs.openclaw.config.channels.discord.accounts.${discordCfg.accountName} = {
        enabled = true;
        # Upstream's oneOf type always commits to "env" variant (all submodules
        # are structurally identical isAttrs), so "file" source can't be used here.
        token = {
          source = "env";
          provider = "discord";
          id = "OPENCLAW_DISCORD_TOKEN";
        };
        allowFrom = discordCfg.allowedUsers;
        dmPolicy = "allowlist";
        groupPolicy = "allowlist";
        actions = {
          messages = true;
          reactions = true;
        };
        commands.native = true;
      };

      systemd.user.services.openclaw-gateway = {
        Service = {
          ExecStartPre = [
            "${pkgs.writeShellScript "openclaw-load-secrets" ''
              printf 'OPENCLAW_DISCORD_TOKEN=%s\nANTHROPIC_API_KEY=%s\nOPENCLAW_GATEWAY_TOKEN=%s\n' \
                "$(cat /run/secrets/openclaw-discord-token)" \
                "$(cat /run/secrets/openclaw-anthropic-key)" \
                "$(cat /run/secrets/openclaw-gateway-token)" \
                > "$XDG_RUNTIME_DIR/openclaw-discord.env"
            ''}"
          ];
          EnvironmentFile = [ "%t/openclaw-discord.env" ];
          ExecStart = lib.mkForce "${pkgs.openclaw}/bin/openclaw gateway --port 18789";
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
