{ pkgs, ... }: {

  home.packages = [
    pkgs.llm-agents.pi
    pkgs.llm-agents.omp
  ];
  # coding-agents = {
  #   pi-coding-agent.enable = true;
  #   pi-coding-agent.extensionsDir = "~/.pi/agent/extra-extensions/";
  # };

  # nixpkgs.overlays = lib.mkAfter [
  #   (_: prev: {
  #     pi-coding-agent = prev.pi-coding-agent.overrideAttrs (old: {
  #       npmDeps = old.npmDeps.overrideAttrs (_: {
  #         outputHash = "sha256-+7Kss4l85CSC84Y9qHp65AXjxIlsWzITPuA6uqQ+9XE=";
  #       });
  #     });
  #   })
  # ];
}
