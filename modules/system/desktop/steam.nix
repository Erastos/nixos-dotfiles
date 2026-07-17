{ config, lib, pkgs, ... }:
let cfg = config.netscape.system.desktop; in
lib.mkIf cfg.steam.enable {
  programs.steam.enable  = true;
  programs.steam.package = pkgs.steam.override {
    extraEnv.STEAM_RUNTIME_PREFER_HOST_LIBRARIES = "0";
  };
  programs.steam.extraCompatPackages = [ pkgs.unstable.proton-ge-bin ];
  programs.steam.extraPackages = with pkgs; [
    # System Wine with X11 support for protontricks GUI tools
    # (Proton's Wine is Wayland-only and doesn't render utility windows on niri)
    wineWow64Packages.stable
    freetype
  ];
  programs.steam.gamescopeSession.enable = true;
  programs.steam.protontricks.enable     = true;
  programs.steam.protontricks.package    = pkgs.unstable.protontricks;
  programs.gamemode.enable               = true;

  # Keychron Q6 Max keyboard: System Control interface is wrongly tagged
  # as a joystick by the kernel. MGSV's FOX Engine reads it as a gamepad
  # and interprets media keys/knob events as phantom axis input, causing
  # menus to scroll and camera to spin uncontrollably.
  services.udev.extraRules = ''
    SUBSYSTEM=="input", ATTRS{name}=="Keychron Keychron Q6 Max System Control", ENV{ID_INPUT_JOYSTICK}=""
  '';

  # Wrap protontricks in steam-run FHS env with system Wine (X11) instead of Proton Wine (Wayland-only)
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "protontricks" ''
      exec ${config.programs.steam.package.run}/bin/steam-run \
        env WINE=/usr/bin/wine WINESERVER=/usr/bin/wineserver \
        ${config.programs.steam.protontricks.package}/bin/protontricks --no-bwrap "$@"
    '')
  ];
}
