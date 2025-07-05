{
  description = "Erastos Config Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    
};
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ...}@inputs: 
    let 
      unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
  {
    nixosConfigurations.Trinity = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs unstable;};
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      modules = 
      [
       /etc/nixos/configuration.nix
       home-manager.nixosModules.home-manager {
	   home-manager.extraSpecialArgs = {inherit unstable;};
           home-manager.useGlobalPkgs = true; 
           home-manager.useUserPackages = true;
           home-manager.users.erastos = {
             imports = [ ];
           };
         }

      ];

    };
  };
}
