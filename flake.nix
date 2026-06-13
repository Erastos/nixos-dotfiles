{
  description = "Netscape's Config Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv.url = "github:cachix/devenv";
    nixpkgs-python = {
      url = "github:cachix/nixpkgs-python";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
    hermes-agent.url = "github:NousResearch/hermes-agent/v2026.5.16";
    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.home-manager.follows = "home-manager";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    den.url = "github:vic/den";
    coding-agents.url = "github:kissgyorgy/coding-agents";
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./parts);
}
