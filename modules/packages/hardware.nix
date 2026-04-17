{ ... }:
{
  nixosModuleLib.hardwarePkgs = { pkgs, ... }:
  {
    home-manager.users.netscape = {
      home.packages = with pkgs; [
        arduino-ide
        platformio
      ];
    };
  };
}
