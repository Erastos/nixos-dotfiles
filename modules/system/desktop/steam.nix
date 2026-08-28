{ config, lib, pkgs, ... }:
let cfg = config.netscape.system.desktop; in
lib.mkIf cfg.steam.enable {
  programs.steam.enable  = true;
  programs.steam.package = pkgs.steam.override {
    extraEnv.STEAM_RUNTIME_PREFER_HOST_LIBRARIES = "0";
  };
  programs.steam.extraCompatPackages = [
    pkgs.unstable.proton-ge-bin
    pkgs.unstable.proton-ge-bin-9
    pkgs.unstable.proton-ge-bin-8
  ];
  programs.steam.extraPackages = with pkgs; [
    # System Wine with X11 support for protontricks GUI tools
    # (Proton's Wine is Wayland-only and doesn't render utility windows on niri)
    wineWow64Packages.stable
    freetype
    mangohud
    fzf
  ];
  programs.steam.gamescopeSession.enable = true;
  programs.steam.protontricks.enable     = true;
  programs.steam.protontricks.package    = pkgs.unstable.protontricks;
  programs.gamemode.enable               = true;
  users.users.netscape.extraGroups        = [ "gamemode" ];

  # Keychron Q6 Max keyboard: System Control interface is wrongly tagged
  # as a joystick by the kernel. MGSV's FOX Engine reads it as a gamepad
  # and interprets media keys/knob events as phantom axis input, causing
  # menus to scroll and camera to spin uncontrollably.
  services.udev.extraRules = ''
    SUBSYSTEM=="input", ATTRS{name}=="Keychron Keychron Q6 Max System Control", ENV{ID_INPUT_JOYSTICK}=""
  '';

  # Script to fix MGSV Phantom Pain phantom-input bug by disabling
  # winebus hidraw — prevents keyboard HID interfaces from being
  # exposed as gamepads to games.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "fix-mgsv-input" ''
      set -e
      PREFIX="$HOME/.steam/steam/steamapps/compatdata/287700/pfx"
      REGFILE="$PREFIX/system.reg"
      if [ ! -f "$REGFILE" ]; then
        echo "MGSV prefix not found at $PREFIX. Launch the game at least once with Proton."
        exit 1
      fi
      if grep -q 'DisableHidraw' "$REGFILE" 2>/dev/null; then
        echo "winebus DisableHidraw already set in MGSV prefix."
      else
        echo "Patching MGSV prefix to disable winebus hidraw..."
        sed -i '/^\[System\\\\ControlSet001\\\\Services\\\\winebus\]/{
          n
          n
          a\"DisableHidraw"=dword:00000001\n"Enable SDL"=dword:00000000
        }' "$REGFILE"
        echo "Done. Restart Steam and launch MGSV."
      fi
    '')

    # Wrap protontricks in steam-run FHS env with system Wine (X11) instead of Proton Wine (Wayland-only)
    (pkgs.writeShellScriptBin "protontricks" ''
      exec ${config.programs.steam.package.run}/bin/steam-run \
        env WINE=/usr/bin/wine WINESERVER=/usr/bin/wineserver \
        ${config.programs.steam.protontricks.package}/bin/protontricks --no-bwrap "$@"
    '')

    (pkgs.writeShellScriptBin "steamid" ''

      STEAM_PATH="$HOME/.local/share/Steam/steamapps"

      if [ -n "''${1}" ]; then
        GAME_SUBSTRING="''${1}"
      else
        GAME_SUBSTRING=""
      fi

      if [ -z "''${GAME_SUBSTRING}" ]; then
        GAMEDIR_BASENAME=$(find "''${STEAM_PATH}/common" -maxdepth 1 ! -name "common" -exec basename {} \; | fzf)
        GAMEDIR="''${STEAM_PATH}/common/''${GAMEDIR_BASENAME}"
      else
        GAMEDIR=$(find "''${STEAM_PATH}/common" -maxdepth 1 -iname "*$GAME_SUBSTRING*")
      fi

      GAMEDIR_LEN=$(wc -l <<< "''${GAMEDIR}")

      if [[ "''${GAMEDIR_LEN}" == "0" ]]; then
        echo "No Game Found..."
        echo "Try a different string"
        exit 1
      elif [[ "''${GAMEDIR_LEN}" == "2" ]]; then
        echo "Found too many games..."
        echo "Use a more specific substring"
        exit 1
      fi

      GAMEDIR_FILENAME=$(basename "''${GAMEDIR}")

      cd $STEAM_PATH
      MANIFEST_FILE=$(rg -l -d 1 "''${GAMEDIR_FILENAME}")
      MANIFEST_FILE_NUM=$(wc -l <<< "''${MANIFEST_FILE}")

      if [[ "''${MANIFEST_FILE_NUM}" == "0" ]]; then
        echo "No Manifest File Located for ''${GAMEDIR_FILENAME}"
        exit 1
      fi

      echo $MANIFEST_FILE | sed -r 's;^.*_(.*).acf$;\1;'
    '')
  ];
}
