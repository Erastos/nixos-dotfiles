{ inputs, lib, ... }: {
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.default = {
    homeManager = {
      home.stateVersion = "22.11";
      nixpkgs.config.allowUnfree = true;
      imports = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.nix-openclaw.homeManagerModules.openclaw
        inputs.coding-agents.homeManagerModules.default
      ];
      _module.args."claude-desktop" = inputs.claude-desktop;
    };
    nixos = {
      system.stateVersion = lib.mkDefault "25.05";
      nixpkgs.config.allowUnfree = true;
      imports = [
        inputs.sops-nix.nixosModules.sops
        inputs.hermes-agent.nixosModules.default
      ];
      _module.args.hermes-agent = inputs.hermes-agent;
    };
  };
}
