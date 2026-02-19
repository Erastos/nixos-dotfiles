{ nixpkgs, home-manager, sops-nix, claude-desktop, overlays }:

{ name, hostType, hardware, systemConfig ? {}, homeConfig ? {}, hostPackages }:

nixpkgs.lib.nixosSystem {
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    inherit overlays;
    config.allowUnfree = true;
  };
  specialArgs = { inherit claude-desktop; };
  modules = [
    ../modules
    sops-nix.nixosModules.sops
    hardware
    ({ lib, ... }: lib.recursiveUpdate {
      system.stateVersion = "25.05";
      netscape.systemName = name;
      netscape.hostType = hostType;
    } systemConfig)
    home-manager.nixosModules.home-manager
    {
      home-manager.extraSpecialArgs = { inherit claude-desktop; };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.netscape = {
        imports = [ ../modules/home hostPackages ];
      } // homeConfig;
    }
  ];
}
