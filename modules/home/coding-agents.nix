{ pkgs, ... }: {

  home.packages = [
    pkgs.llm-agents.pi
    (pkgs.llm-agents.omp.override {
      # The unstable Rust toolchain emits native code against its newer glibc.
      # Keep the addon and its runtime libraries on the same libc.
      stdenv = pkgs.unstable.stdenv;
      zlib = pkgs.unstable.zlib;
      pipewire = pkgs.unstable.pipewire;
      libpulseaudio = pkgs.unstable.libpulseaudio;
      rustc = pkgs.unstable.rustc;
      cargo = pkgs.unstable.cargo;
      rustPlatform = pkgs.unstable.rustPlatform;
    })
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
