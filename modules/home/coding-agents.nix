{ inputs, lib, ... }: {
  coding-agents = {
    pi-coding-agent.enable = true;
    pi-coding-agent.extensionsDir = "~/.pi/agent/extra-extensions/";
  };

  nixpkgs.overlays = lib.mkAfter [
    (_: prev: {
      pi-coding-agent = prev.pi-coding-agent.overrideAttrs (old: {
        npmDeps = old.npmDeps.overrideAttrs (_: {
          outputHash = "sha256-rnpzB3FiOhHXcNjxBe0evGE1h/mBf6UyXZaJRtzIGKE=";
        });
      });
    })
  ];
}
