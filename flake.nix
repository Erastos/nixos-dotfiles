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
};
  outputs = { self, nixpkgs, home-manager, nixos-hardware, hyprland, ...}@inputs: {
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
      specialArgs = { inherit inputs;};
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      modules = 
      [
       ./hosts/system/Serenity.nix 
       ./hardware/Serenity.nix
       home-manager.nixosModules.home-manager {
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
