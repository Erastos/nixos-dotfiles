{
  description = "Netscape's Config Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ...}:
    let
      system = "x86_64-linux";
      overlays = [(import ./overlays/ldapdomaindump.nix) ];
      pkgs = import nixpkgs { inherit system overlays; config.allowUnfree = true;};
      unstable = import nixpkgs-unstable { inherit system overlays; config.allowUnfree = true;};
      colors = ./modules/colors/red.nix;
    in
    {
      nixosConfigurations.Trinity = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = {inherit unstable;};
        modules = [
         ./modules/basic.nix
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
         ./modules/fonts.nix
         ./modules/steam.nix
         ./modules/lix.nix
         ./modules/tailscale.nix

         ./modules/zsh/editor.nix
         ./modules/podman.nix


         ./hardware/Trinity.nix

         ({ config, lib, pkgs, ... }: {
           system.stateVersion = "25.05";
           systemName = "Trinity";
         })
       
         home-manager.nixosModules.home-manager {
           home-manager.extraSpecialArgs = { inherit unstable; };
           home-manager.useGlobalPkgs = true; 
           home-manager.useUserPackages = true;
           home-manager.users.netscape = {
             imports = [
               ./hosts/Trinity.nix
               ./modules/git.nix
               ./modules/zsh/main.nix
               ./modules/zsh/aliases.nix
               ./modules/zsh/antidote.nix
               ./modules/tmux.nix
               ./modules/neovim.nix
               ./modules/wezterm.nix
             ];
           };
         }
      ];
    };

    nixosConfigurations.Neo = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = {inherit unstable;};
        modules = [
          ./modules/basic.nix
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
          ./modules/nix-command.nix
          ./modules/intel.nix
          ./modules/fonts.nix
          ./modules/lix.nix
          ./modules/tailscale.nix
          ./modules/graphics.nix
          ./modules/sway.nix

          ./modules/zsh/editor.nix
          ./modules/podman.nix

          ./hardware/Neo.nix

          ({ config, lib, pkgs, ... }: {
            system.stateVersion = "25.05";
            systemName = "Neo";
          })

          home-manager.nixosModules.home-manager {
              home-manager.extraSpecialArgs = { inherit unstable; };
              home-manager.useGlobalPkgs = true; 
              home-manager.useUserPackages = true;
              home-manager.users.netscape = {
                imports = [
                  colors
                  ./hosts/Neo.nix
                  ./modules/git.nix
                  ./modules/zsh/main.nix
                  ./modules/zsh/aliases.nix
                  ./modules/zsh/antidote.nix
                  ./modules/tmux.nix
                  ./modules/neovim.nix
                  ./modules/wezterm.nix
                  ./modules/foot.nix
                  ./modules/river.nix
                  ./modules/waybar.nix
              ];
            };
          }
        ];
      };
    };
}
