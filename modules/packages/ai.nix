{ config, lib, pkgs, claude-desktop, ... }:

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

  ]);
}
