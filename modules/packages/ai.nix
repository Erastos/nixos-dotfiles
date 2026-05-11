{ config, lib, pkgs, claude-desktop, hermes-agent, ... }:

let
  cfg = config.netscape.packages.ai;
  chromium-steam = pkgs.writeShellScriptBin "chromium" ''
    exec ${pkgs.steam-run}/bin/steam-run ${pkgs.chromium}/bin/chromium "$@"
  '';
  openclaw-cli = pkgs.runCommand "openclaw-cli"
    { meta = pkgs.unstable.openclaw.meta or {}; }
    ''
      mkdir -p $out/bin
      for f in ${pkgs.unstable.openclaw}/bin/*; do
        name=$(basename "$f")
        [ "$name" = "corepack" ] && continue
        ln -s "$f" "$out/bin/$name"
      done
    '';
in
{
  options.netscape.packages.ai = {
    enable = lib.mkEnableOption "AI Packages" // { default = true; };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # ── Home packages (all hosts) ────────────────────────────────────────
    {
      home-manager.users.netscape = {
        home.packages = [
          pkgs.unstable.opencode
          pkgs.unstable.claude-code
          claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs
          pkgs.beads
          pkgs.gastown
        ];
      };
    }

    # ── Hermes gateway (Trinity only) ───────────────────────────────────
    (lib.mkIf (config.netscape.systemName == "Trinity") {
      programs.nix-ld.enable = true;

      sops.secrets."hermes/env" = {
        sopsFile = ../../secrets/secrets.yaml;
        key = "hermes/env";
        mode = "0400";
        owner = "root";
      };

      systemd.services.hermes-agent.environment.HERMES_OPTIONAL_SKILLS =
        "${hermes-agent}/optional-skills";
      environment.variables.HERMES_OPTIONAL_SKILLS =
        "${hermes-agent}/optional-skills";

      services.hermes-agent = {
        enable = true;
        user = "netscape";
        group = "users";
        createUser = false;
        extraPackages = [ chromium-steam ];
        settings = {
          model.default = "google/gemini-2.5-flash";
          # model.default = "anthropic/claude-sonnet-4-6";
          # model.provider = "anthropic";
          model.provider = "openrouter";
          approvals.mode = "on";
          platform_toolsets.discord = [
            "terminal" "file" "web" "vision" "browser"
            "skills" "todo" "cronjob" "send_message"
          ];
          discord = {
            require_mention = true;
            auto_thread = true;
            reactions = true;
          };
        };
        environmentFiles = [ config.sops.secrets."hermes/env".path ];
        addToSystemPackages = true;
      };

      # system.activationScripts."hermes-claude-credentials" = lib.stringAfter [ "hermes-agent-setup" ] ''
      #   ln -sfn /home/netscape/.claude /var/lib/hermes/.claude
      # '';
    })
  ]);
}
