# { pkgs, config, hermes-agent, ... }:
# let
#   chromium-steam = pkgs.writeShellScriptBin "chromium" ''
#     exec ${pkgs.steam-run}/bin/steam-run ${pkgs.chromium}/bin/chromium "$@"
#   '';
# in {
#   sops.secrets."hermes/env" = {
#     sopsFile = ../../secrets/secrets.yaml;
#     key      = "hermes/env";
#     mode     = "0400";
#     owner    = "root";
#   };
#
#   systemd.services.hermes-agent.environment.HERMES_OPTIONAL_SKILLS =
#     "${hermes-agent}/optional-skills";
#   environment.variables.HERMES_OPTIONAL_SKILLS = "${hermes-agent}/optional-skills";
#
#   services.hermes-agent = {
#     enable                = true;
#     user                  = "netscape";
#     group                 = "users";
#     createUser            = false;
#     extraPackages         = [ chromium-steam ];
#     extraDependencyGroups = [ "messaging" ];
#     settings = {
#       model.default   = "google/gemini-2.5-flash";
#       model.provider  = "openrouter";
#       approvals.mode  = "on";
#       platform_toolsets.discord = [
#         "terminal" "file" "web" "vision" "browser"
#         "skills" "todo" "cronjob" "send_message"
#       ];
#       discord = { require_mention = true; auto_thread = true; reactions = true; };
#     };
#     environmentFiles    = [ config.sops.secrets."hermes/env".path ];
#     addToSystemPackages = true;
#   };
# }

{ pkgs, config, hermes-agent, ... }: {

  sops.secrets."hermes/env" = {
    sopsFile = ../../secrets/secrets.yaml;
    key = "hermes/env";
    mode = "0444";
    owner = "hermes";
  };

  services.hermes-agent = {
    enable = true;
    container.enable = true;
    container.hostUsers = ["netscape"];
    extraDependencyGroups = [ "messaging" ];
    extraPackages = [ pkgs.python312Packages.ddgs ];
    extraPythonPackages = [ pkgs.python312Packages.ddgs ];
    settings = {
      model.default = "anthropic/claude-sonnet-4.6";
      model.provider = "openrouter";
      approvals.mode = "on";
      web.backend = "ddgs";
      toolsets = ["all"];
      discord = {
        require_mention = true;
        auto_thread = true;
        reactions = true;
      };
    };
    environmentFiles = [ config.sops.secrets."hermes/env".path ];
    addToSystemPackages = true;
  };
}
