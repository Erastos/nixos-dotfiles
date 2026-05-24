{ lib, ... }: {
  imports = [
    ./plasma.nix
    ./niri.nix
    ./sway.nix
    ./steam.nix
  ];

  options.netscape.system.desktop = {
    plasma.enable = lib.mkEnableOption "KDE Plasma 6 desktop";
    sway.enable   = lib.mkEnableOption "Sway compositor";
    niri.enable   = lib.mkEnableOption "niri scrollable tiling compositor";
    steam.enable  = lib.mkEnableOption "Steam gaming platform";
  };
}
