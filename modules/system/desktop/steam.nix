{ ... }:
{
  nixosModuleLib.steam = { config, pkgs, ... }:
  {
    programs.steam.enable = true;
    programs.steam.extraCompatPackages = [ pkgs.unstable.proton-ge-bin ];
    programs.steam.extraPackages = with pkgs; [
      wineWow64Packages.stable
      freetype
    ];
    programs.steam.gamescopeSession.enable = true;
    programs.steam.protontricks.enable = true;
    programs.steam.protontricks.package = pkgs.unstable.protontricks;
    programs.gamemode.enable = true;

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "protontricks" ''
        exec ${config.programs.steam.package.run}/bin/steam-run \
          env WINE=/usr/bin/wine WINESERVER=/usr/bin/wineserver \
          ${config.programs.steam.protontricks.package}/bin/protontricks --no-bwrap "$@"
      '')
    ];
  };
}
