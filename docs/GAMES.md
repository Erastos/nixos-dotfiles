# Game fixes

Game-specific workarounds in this NixOS configuration, plus local settings that must be applied by hand. The Steam module is enabled for [Trinity](../parts/aspects/Trinity.nix); a Nix-defined command being installed does **not** mean it has been run against an existing Steam prefix.

## Metal Gear Solid V: The Phantom Pain (Steam app 287700)

[Source: `modules/system/desktop/steam.nix`](../modules/system/desktop/steam.nix)

The Keychron Q6 Max *System Control* interface can be misidentified as a joystick. MGSV's FOX Engine then treats media-key/knob events as gamepad input, scrolling menus or spinning the camera. The Steam module installs a udev rule that clears `ID_INPUT_JOYSTICK` for this particular keyboard interface. The rule applies to that device system-wide when the Steam module is enabled; it does not match MGSV's process or edit its Proton prefix.

The same module installs `fix-mgsv-input` for the separate Proton/winebus phantom-input issue. **Run it manually** after MGSV has created its Proton prefix. It edits `~/.steam/steam/steamapps/compatdata/287700/pfx/system.reg` to set `DisableHidraw=1` and `Enable SDL=0` under `System\ControlSet001\Services\winebus`, preventing HID/SDL keyboard interfaces from being exposed to the game as gamepads. The script leaves the file unchanged when those values are already present, reports an error if the prefix or registry key is missing, and asks you to restart Steam after a change. These settings are scoped to this Steam app's prefix; they are **not** applied just by rebuilding NixOS.

## SYNTHETIK 2 (Steam app 1471410)

**Manual Steam/Proton settings, not a game-specific Nix patch.** The [Steam module](../modules/system/desktop/steam.nix) supplies MangoHud, but neither this game's settings file nor its launch options are managed by Nix.

- **Full-screen monitor:** On the ASUS DP-2 (2560×1440 @ 144 Hz) with a Dell DP-1 (1920×1200), the game initially drew a 1920×1200 inner image despite requesting `2560x1440x144`. Close the game and change `VideoSettings.TargetDisplaySetting._value` from `0` to `1` in `$HOME/.local/share/Steam/steamapps/compatdata/1471410/pfx/drive_c/users/steamuser/AppData/LocalLow/FlowFire/Synthetik2/Settings.json`. Leave the requested resolution unchanged. `1` worked for this direct-launch monitor ordering; it is **not** a universal display index. Recheck after changing displays or launch mode. An original backup was saved alongside the settings as `Settings.json.prime-backup-20261106`.
- **Frame limit:** In Steam → SYNTHETIK 2 → Properties → General → Launch Options, use `MANGOHUD=1 MANGOHUD_CONFIG=fps_limit=90,no_display=1 %command%`. This uses a hidden 90 FPS MangoHud cap and launches the game directly, without Gamescope. To remove the cap, restore `%command%`; you can keep the display change independently. Restoring the backup `Settings.json` reverts **all** settings captured in it, not just the display index.

A short, stationary solo Tutorial comparison showed 12.42 ms p95 frametime at 90 FPS capped versus 15.41 ms uncapped. That is limited evidence for frame consistency in that scene, not proof of smooth heavy combat or that Gamescope caused previous stutter (the captured Gamescope run had a different nested refresh rate).

## Shared Steam setup (not per-game patches)

The [Steam module](../modules/system/desktop/steam.nix) enables Steam, GameMode and Gamescope sessions, sets `STEAM_RUNTIME_PREFER_HOST_LIBRARIES=0`, and provides Proton GE, Proton CachyOS and MangoHud. [Older Proton GE builds](../overlays/unstable/proton-ge-old.nix) package pinned upstream releases; they are **not** source-code patches or assigned to a particular game.

The Steam module also wraps `protontricks` in `steam-run` with system X11 Wine so its GUI works on niri, and provides `steamid` to look up installed game app IDs. In the [niri session](../modules/system/desktop/niri.nix), `SDL_VIDEODRIVER=wayland` is deliberately not set globally because it breaks Steam's XWayland processes. These are shared compatibility choices, **not** per-game settings or declarations of Steam launch options.
