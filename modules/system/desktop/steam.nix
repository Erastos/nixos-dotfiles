{ config, lib, pkgs, ... }:
let cfg = config.netscape.system.desktop; in
lib.mkIf cfg.steam.enable {
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraEnv.STEAM_RUNTIME_PREFER_HOST_LIBRARIES = "0";
    };
    extraCompatPackages = [
      pkgs.unstable.proton-ge-bin
      pkgs.unstable.proton-ge-bin-9
      pkgs.unstable.proton-ge-bin-8
      pkgs.proton-cachyos
    ];
    extraPackages = with pkgs; [
      # System Wine with X11 support for protontricks GUI tools
      # (Proton's Wine is Wayland-only and doesn't render utility windows on niri)
      wineWow64Packages.stable
      freetype
      mangohud
      fzf
    ];
    gamescopeSession.enable = true;
    # The FHS wrapper below supplies protontricks; enabling the built-in
    # package would install a second command with the same name.
  };
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
    pkgs.ludusavi
    (pkgs.writeShellApplication {
      name = "fix-mgsv-input";
      runtimeInputs = with pkgs; [ coreutils gawk ];
      text = ''
        set -euo pipefail
        prefix="$HOME/.steam/steam/steamapps/compatdata/287700/pfx"
        regfile="$prefix/system.reg"
        if [[ ! -f "$regfile" ]]; then
          echo "MGSV prefix not found at $prefix. Launch the game at least once with Proton." >&2
          exit 1
        fi

        tmp=$(mktemp "$prefix/.system.reg.XXXXXXXX")
        trap 'rm -f -- "$tmp"' EXIT
        if ! awk '
          function finish_section() {
            if (in_winebus) {
              if (!hidraw) print "\"DisableHidraw\"=dword:00000001"
              if (!sdl) print "\"Enable SDL\"=dword:00000000"
            }
          }
          /^\[/ {
            finish_section()
            in_winebus = index($0, "[System\\\\ControlSet001\\\\Services\\\\winebus]") == 1
            if (in_winebus) seen = 1
            hidraw = sdl = 0
          }
          in_winebus && /^"DisableHidraw"=/ {
            print "\"DisableHidraw\"=dword:00000001"
            hidraw = 1
            next
          }
          in_winebus && /^"Enable SDL"=/ {
            print "\"Enable SDL\"=dword:00000000"
            sdl = 1
            next
          }
          in_winebus && /^$/ {
            finish_section()
            in_winebus = 0
          }
          { print }
          END {
            finish_section()
            if (!seen) exit 1
          }
        ' "$regfile" > "$tmp"; then
          echo "winebus registry key not found in MGSV prefix: $regfile" >&2
          exit 1
        fi

        if cmp -s -- "$regfile" "$tmp"; then
          echo "winebus DisableHidraw and Enable SDL already set in MGSV prefix."
        else
          chmod --reference="$regfile" "$tmp"
          mv -f -- "$tmp" "$regfile"
          echo "Done. Restart Steam and launch MGSV."
        fi
      '';
    })

    # Wrap protontricks in steam-run FHS env with system Wine (X11) instead of Proton Wine (Wayland-only)
    (pkgs.writeShellScriptBin "protontricks" ''
      exec ${config.programs.steam.package.run}/bin/steam-run \
        env WINE=/usr/bin/wine WINESERVER=/usr/bin/wineserver \
        ${pkgs.unstable.protontricks}/bin/protontricks --no-bwrap "$@"
    '')

    (pkgs.writeShellScriptBin "steamid" ''
      set -euo pipefail
      steam_path="$HOME/.local/share/Steam/steamapps"
      common_path="$steam_path/common"

      if [[ ! -d "$common_path" ]]; then
        echo "Steam game directory not found: $common_path" >&2
        exit 1
      fi

      if [[ -n "''${1:-}" ]]; then
        mapfile -d "" -t games < <(${pkgs.findutils}/bin/find "$common_path" -mindepth 1 -maxdepth 1 \
          \( -type d -o -type l \) -iname "*$1*" -print0)
        case "''${#games[@]}" in
          0) echo "No game found for: $1" >&2; exit 1 ;;
          1) game="''${games[0]##*/}" ;;
          *) echo "Found too many games for: $1. Use a more specific substring." >&2; exit 1 ;;
        esac
      else
        game=$(${pkgs.findutils}/bin/find "$common_path" -mindepth 1 -maxdepth 1 \
          \( -type d -o -type l \) -printf '%f\n' | ${pkgs.fzf}/bin/fzf) || exit 1
        [[ -n "$game" ]] || exit 1
      fi

      shopt -s nullglob
      matches=()
      for manifest in "$steam_path"/appmanifest_*.acf; do
        if ${pkgs.gawk}/bin/awk -F '"' -v game="$game" \
          '$2 == "installdir" && $4 == game { found=1; exit } END { exit !found }' "$manifest"; then
          matches+=("$manifest")
        fi
      done

      case "''${#matches[@]}" in
        0) echo "No manifest found for: $game" >&2; exit 1 ;;
        1) ;;
        *) echo "Multiple manifests found for: $game" >&2; exit 1 ;;
      esac
      manifest="''${matches[0]##*/}"
      app_id="''${manifest#appmanifest_}"
      printf '%s\n' "''${app_id%.acf}"
    '')
  ];
}
