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
      specialArgs = { inherit unstable; };
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      modules = [

       ./modules/boot/systemd-boot.nix
       ./modules/kernel.nix
       ./modules/network.nix
       ./modules/time.nix
       ./modules/locale.nix
       ./modules/cups.nix
       ./modules/audio/pipewire.nix
       ./modules/touchpad.nix
       ./modules/users.nix
       ./modules/web/firefox.nix
       ./modules/ssh.nix
       ./modules/base-packages.nix
       ./modules/plasma.nix
       ./modules/nvidia.nix
       ./modules/nix-command.nix
       ./modules/steam.nix
       ./modules/font.nix


       ./hardware-configuration.nix


       ({ config, lib, pkgs, ... }: { system.stateVersion = "25.05"; })
      
       home-manager.nixosModules.home-manager {
           home-manager.extraSpecialArgs = { inherit unstable; };
           home-manager.useGlobalPkgs = true; 
           home-manager.useUserPackages = true;
           home-manager.users.netscape = {
             imports = [
               ./hosts/Trinity.nix
               ./modules/git.nix
               ./modules/zsh/main.nix
               ./modules/zsh/prezto.nix
             ];
           };
         }
      ];

    };
  };
}
