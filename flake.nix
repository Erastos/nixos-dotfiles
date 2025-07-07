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
        overlays = [
          ( self: super: {
              python313 = super.python313.override {
                packageOverrides = pythonSelf: pythonSuper: {
                  ldapdomaindump = pythonSuper.ldapdomaindump.overridePythonAttrs (oldAttrs: {
                    version = "0.10.0";
                    src = super.fetchPypi {
                      version = "0.10.0";
                      pname = "ldapdomaindump";
                      hash = "sha256-y8ZrMqd4dHP/0WnFMZrN5GwC/cnURFVuZEjg3vkdMpk=";
                    };
                    propagatedBuildInputs = ( builtins.filter (x: x.name != pythonSuper.future.name) oldAttrs.propagatedBuildInputs );
                    nativeBuildInputs = [ pythonSuper.pip  ];
                    installPhase = ''
                      runHook preInstall

                      pushd dist >/dev/null

                      for wheel in *.whl; do
                        echo $wheel;
                        ${super.python313}/bin/python -m pip install --prefix "$out" "$wheel"
                      done;

                      popd >/dev/null

                      export PYTHONPATH="$out/lib/python3.13/site-packages:$PYTHONPATH"

                      runHook postInstall
                    '';
                  });
                };
              };
            } 
          )
        ];
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
       ./modules/fonts.nix

       ./modules/zsh/editor.nix


       ./hardware-configuration.nix


       ({ config, lib, pkgs, ... }: { system.stateVersion = "25.05"; })
       
       # ({ config, lib, pkgs, ... }: { environment.systemPackages = [pkgs.python313Packages.impacket] ; })
       # ({ config, lib, pkgs, ... }: { environment.systemPackages = [] ; })
      
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
               ./modules/zsh/prezto.nix
               ./modules/tmux.nix
               ./modules/neovim.nix
             ];
           };
         }
      ];

    };
  };
}
