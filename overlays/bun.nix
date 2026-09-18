# nixpkgs 26.05 (stable) pins bun at 1.3.13 and will not receive a routine bump.
# llm-agents.nix's `omp` package needs the *running* bun (used to compile its
# standalone binary) to be >= 1.4.0 (oven-sh/bun#31024); otherwise bun2nixLib.hook
# — built against our own stable bun — shadows the newer bun on PATH during the
# build, so the compiled binary embeds bun 1.3.13's runtime and crashes with
# "TypeError: Expected CommonJS module to have a function wrapper." Take bun from
# the unstable overlay instead, which already ships 1.4.2.
final: _prev: {
  bun = final.unstable.bun;
}
