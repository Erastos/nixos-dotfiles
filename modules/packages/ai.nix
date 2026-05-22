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

      users.users.netscape = {
        extraGroups = [ "hermes" ];
      };

      services.hermes-agent = {
        enable = true;
        container = {
          enable = true;
          hostUsers = [ "netscape" ];
        };

        addToSystemPackages = true;
        environmentFiles = [ config.sops.secrets."hermes/env".path ];
        extraDependencyGroups = [ "messaging" ];
        settings = {
          model = {
            default = "google/gemini-2.5-flash";
          };
          toolsets = [ "all" ];
          gateway.discord = {
            require_mention = true;
            auto_thread = true;
            reactions = true;
          };
        };
      };

    })
  ]);
}
