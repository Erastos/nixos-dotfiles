{ pkgs, ... }: {

  home.packages = [
    pkgs.llm-agents.pi
    pkgs.llm-agents.orca
    pkgs.llm-agents.prime-agent
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
}
