{
  description = "Erastos Config Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:/NixOS/nixos-hardware/master";
    hyprland.url = "github:hyprwm/Hyprland";
    poetry2nix.url = "github:nix-community/poetry2nix/";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    
};
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, hyprland, poetry2nix, ...}@inputs: 
    let 
      unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
  {
    nixosConfigurations.Rogue = nixpkgs.lib.nixosSystem {
      specialArgs = inputs;
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      modules = 
      [
       ./hosts/system/Rogue.nix 
       ./hardware/Rogue.nix
       ./modules/podman.nix
       ./modules/neo4j.nix
       nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
       home-manager.nixosModules.home-manager {
           home-manager.useGlobalPkgs = true; 
           home-manager.useUserPackages = true;
           home-manager.users.erastos = {
             imports = [ ./hosts/home/Rogue.nix ];
           };
         }
      ];

    };

    nixosConfigurations.Serenity = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs unstable;};
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      modules = 
      [
       ./hosts/system/Serenity.nix 
       ./hardware/Serenity.nix
       ./modules/i3
       ./modules/lightdm.nix
       ./modules/gtk.nix
       ./modules/steam.nix
       home-manager.nixosModules.home-manager {
	   home-manager.extraSpecialArgs = {inherit unstable;};
           home-manager.useGlobalPkgs = true; 
           home-manager.useUserPackages = true;
           home-manager.users.erastos = {
             imports = [ ./hosts/home/Serenity.nix ];
           };
         }

      ];

    };
};

}
