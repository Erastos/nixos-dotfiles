# Den Framework Migration Plan

## Overview

This config uses a traditional layered approach: `mkHost.nix` assembles each host by combining
NixOS + embedded home-manager modules, threading values via `specialArgs`/`extraSpecialArgs`.
Feature config is split across `modules/system/` (NixOS) and `modules/home/` (HM) with no
structural relationship between the two sides of the same feature.

The goal is to migrate to the **Den framework** where:
- Every `.nix` file is a top-level flake-parts module, auto-imported via `import-tree`
- **Aspects** own a full feature (NixOS + HM in one file, not split by layer)
- `den.hosts` / `den.homes` replace `mkHost.nix`; Den calls `lib.nixosSystem` for you
- Parametric dispatch (`{host}:`, `{host, user}:`) replaces `hostType == "laptop"` conditionals
- No `specialArgs` — values flow through the top-level `config`

The `netscape.system.*` and `netscape.home.*` option namespaces do not need to change.
Only the assembly mechanism changes, not the module contents.

References:
- Den docs: https://den.oeiuwq.com/
- Den source: https://github.com/vic/den
- Dendritic pattern: https://github.com/mightyiam/dendritic
- Example implementation (this repo's reference): https://github.com/danielgafni/nixos

---

## Phase 1 — Bootstrap flake-parts

**Goal:** Replace the raw `outputs` function with `flake-parts`, without touching anything else.
All existing builds should be byte-for-byte identical after this phase.

### Step 1.1 — Add inputs to `flake.nix`

Add these three inputs inside the `inputs = { ... }` block:

```nix
flake-parts.url  = "github:hercules-ci/flake-parts";
import-tree.url  = "github:vic/import-tree";
den.url          = "github:vic/den";
```

Leave everything else in `inputs` untouched. `flake-utils` stays for now.

### Step 1.2 — Create `parts/systems.nix`

```nix
{ systems = [ "x86_64-linux" ]; }
```

### Step 1.3 — Create `parts/devshells.nix`

This wraps the existing `shells/default.nix` call. `perSystem` gives you the current system
and pkgs automatically:

```nix
{ inputs, ... }: {
  perSystem = { system, ... }: {
    devShells = import ../shells { inherit system inputs; };
  };
}
```

### Step 1.4 — Create `parts/hosts.nix`

Extract the entire `let … in { nixosConfigurations = … }` block from `flake.nix` into this
file. The overlay construction and `mkHost` calls move here verbatim:

```nix
{ inputs, ... }:
let
  system = "x86_64-linux";

  overlays = builtins.map (name: import (../overlays + "/${name}"))
    (builtins.filter (name: builtins.match ".*\\.nix$" name != null)
      (builtins.attrNames (builtins.readDir ../overlays)));

  unstableOverlay = final: prev: let
    unstablePkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [ "openclaw-2026.4.12" ];
      overlays = [ inputs.nix-openclaw.overlays.default ];
    };
  in {
    unstable = unstablePkgs;
    inherit (unstablePkgs) openclaw openclawPackages;
  };

  allOverlays = [ unstableOverlay ] ++ overlays;

  mkHost = import ../lib/mkHost.nix {
    inherit (inputs) nixpkgs home-manager sops-nix claude-desktop hermes-agent nix-openclaw;
    overlays = allOverlays;
  };
in
{
  flake.nixosConfigurations.Trinity = mkHost {
    name         = "Trinity";
    hostType     = "desktop";
    hardware     = ../hardware/Trinity.nix;
    hostPackages = ../hosts/Trinity.nix;
    systemConfig = {
      netscape.system.networking.firewall.http.enable = true;
      netscape.system.htb.enable                      = true;
      netscape.system.virtualisation.vmware.enable    = true;
      netscape.system.virtualisation.qemu.enable      = true;
      netscape.system.desktop.plasma.enable           = false;
      netscape.system.desktop.niri.enable             = true;
      netscape.system.services.docker.enable          = true;
    };
    homeConfig = {
      netscape.home.colors.enable       = true;
      netscape.home.colors.scheme       = "cyberpunk-neon";
      netscape.home.terminals.foot.enable = true;
      netscape.home.wm.niri.enable      = true;
      netscape.home.wm.waybar.enable    = true;
      netscape.home.theming.enable      = true;
    };
  };

  flake.nixosConfigurations.Neo = mkHost {
    name         = "Neo";
    hostType     = "laptop";
    hardware     = ../hardware/Neo.nix;
    hostPackages = ../hosts/Neo.nix;
    systemConfig = {
      netscape.system.networking.firewall.http.enable = true;
      netscape.system.htb.enable                      = true;
      netscape.system.virtualisation.qemu.enable      = true;
      netscape.system.services.docker.enable          = true;
    };
    homeConfig = {
      netscape.home.wm.waybar.enable    = true;
      netscape.home.theming.enable      = true;
      netscape.home.theming.gtkTheme    = "Tokyonight-Dark";
    };
  };
}
```

### Step 1.5 — Replace `outputs` in `flake.nix`

Replace the entire `outputs = { self, ... }@inputs: let … in { … };` block with:

```nix
outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
  (inputs.import-tree ./parts);
```

The `let` block that built `overlays`, `unstableOverlay`, `allOverlays`, and `mkHost` is now
in `parts/hosts.nix`, so delete it from `flake.nix`. The inputs destructuring in the old
`outputs` signature is also no longer needed — flake-parts receives `inputs` as an attrset.

> **Note:** `import-tree` skips directories named `archive`, `_*`, and files matching `_*`,
> so `modules/archive/` will be ignored automatically. No action needed there.

### Step 1.6 — Verify

```bash
# These should produce identical hashes before and after
nix eval .#nixosConfigurations.Trinity.config.system.build.toplevel
nix eval .#nixosConfigurations.Neo.config.system.build.toplevel

# Dev shells should still work
nix develop .#python --command echo ok
```

---

## Phase 2 — Introduce Den and declare topology

**Goal:** Add Den and establish the host/home/aspect skeleton alongside `mkHost.nix`. Nothing
changes about how hosts build. Den aspects are declared but not yet wired into any build.

### Step 2.1 — Create `parts/den.nix`

```nix
{ inputs, den, lib, ... }: {
  imports = [ inputs.den.flakeModule ];

  # No embedded HM — all homes are standalone (built via `nh home switch`).
  # Setting user classes to [] means no user gets the "homeManager" class,
  # so den.batteries.home-manager never enables home-manager on any host.
  den.schema.user.classes = lib.mkDefault [];

  # Suppress Den's automatic output generation — parts/hosts.nix owns
  # nixosConfigurations and homeConfigurations until Phase 5.
  # Without this, Den generates flake.nixosConfigurations.* from den.hosts
  # which conflicts with the mkHost.nix definitions in parts/hosts.nix.
  den.schema.flake-system.excludes = [
    den.policies.system-to-os-outputs
    den.policies.system-to-hm-outputs
  ];

  den.default = {
    homeManager = {
      home.stateVersion              = "22.11";
      nixpkgs.config.allowUnfree     = true;
    };
    nixos = {
      system.stateVersion            = lib.mkDefault "25.05";
      nixpkgs.config.allowUnfree     = true;
    };
  };

  # Host topology — user aspects will be filled in Phase 5
  den.hosts.x86_64-linux = {
    Trinity.users.netscape.aspect = den.aspects.netscape-linux;
    Neo.users.netscape.aspect     = den.aspects.netscape-linux;
  };

  # Standalone home configurations
  den.homes.x86_64-linux = {
    "netscape@Trinity".aspect = den.aspects.netscape-linux;
    "netscape@Neo".aspect     = den.aspects.netscape-linux;
  };

  # Placeholder aspects — filled in across Phases 3–6
  den.aspects = {
    shared-nixos = {};    # will hold shared NixOS modules
    shared-hm    = {};    # will hold shared HM modules

    Trinity = {
      includes = [ den.batteries.hostname ];
      nixos.imports = [ ../hardware/Trinity.nix ];
    };

    Neo = {
      includes = [ den.batteries.hostname ];
      nixos.imports = [ ../hardware/Neo.nix ];
    };

    netscape = {
      includes = [ den.batteries.define-user den.batteries.primary-user ];
    };

    netscape-linux = {
      includes = [ den.aspects.netscape ];
    };
  };
}
```

### Step 2.2 — Verify

```bash
# Builds must still be identical — Den aspects are empty and not connected to mkHost yet
nix eval .#nixosConfigurations.Trinity.config.system.build.toplevel
nix eval .#nixosConfigurations.Neo.config.system.build.toplevel

# Den topology should evaluate without error (outputs suppressed until Phase 5)
nix eval .#den
```

---

## Phase 3 — Migrate system modules into the shared NixOS aspect

**Goal:** Move `modules/system/*.nix` into `den.aspects.shared-nixos` one at a time.
`mkHost.nix` stays as the build path throughout this phase. After each module is migrated,
the host build should produce an identical derivation.

### Step 3.1 — Declare modules in `shared-nixos` alongside `mkHost.nix`

`mkHost.nix` remains the active build path throughout Phase 3 — do not touch it.
The Den aspects are built up in parallel as declarations only; they do not feed into
any build yet. Do **not** remove modules from `modules/system/default.nix` during this
phase.

> **Why not thread aspect content into mkHost?** Den aspects store their class content
> (`nixos`, `homeManager`, etc.) as `aspectKeyType` values processed by the Den pipeline,
> not as plain NixOS modules. There is no safe way to extract them back out and inject
> them into an external `lib.nixosSystem` call.

### Step 3.2 — Declare modules one by one

For each module below, follow this procedure:

**a)** Open the module. Confirm it is a self-contained NixOS module (takes `{ config, lib, pkgs, ... }`).

**b)** In `parts/den.nix`, add it to `den.aspects.shared-nixos` (leaving `modules/system/default.nix` unchanged):
```nix
den.aspects.shared-nixos = {
  nixos.imports = [
    ../modules/system/secrets.nix   # add one at a time
  ];
};
```

**c)** Verify the build is still identical (modules/system/default.nix still has the import):
```bash
nixos-rebuild dry-run --flake .#Trinity 2>&1 | grep -E "^(will|these)"
# Should output nothing — no changes
```

**Migration order:**

| # | File | Notes |
|---|------|-------|
| 1 | `modules/system/secrets.nix` | Self-contained, no cross-module deps |
| 2 | `modules/system/audio.nix` | Self-contained |
| 3 | `modules/system/users.nix` | Sets up the `netscape` user; no cross-module deps |
| 4 | `modules/system/networking.nix` | Reads only `config.netscape.system.networking.*` |
| 5 | `modules/system/hardware.nix` | CPU/GPU options |
| 6 | `modules/system/services.nix` | Docker, Bluetooth, etc. |
| 7 | `modules/system/virtualization.nix` | QEMU/KVM, VMware |
| 8 | `modules/system/htb.nix` | HTB-specific tooling |
| 9 | `modules/system/desktop.nix` | Display manager — has `hostType` logic (see note) |
| 10 | `modules/system/core.nix` | Most foundational — contains `netscape.systemName` and `netscape.hostType` options |
| 11 | `modules/system/openclaw.nix` | Experimental, low risk |

> **Note on `desktop.nix`:** It uses `config.netscape.hostType` to set defaults. Because
> `core.nix` (step 10) defines that option, migrate `desktop.nix` **before** `core.nix` only
> if you verify the option is still accessible — or swap the order and do `core.nix` at step 9.

### Step 3.3 — (Deferred) Clean up `modules/default.nix`

The cleanup of `modules/system/default.nix`, `modules/packages/default.nix`, and
`modules/default.nix` happens after Phase 5, once `mkHost.nix` is deleted and Den owns
the build. Do not touch these files during Phase 3.

---

## Phase 4 — Migrate home-manager modules into the shared HM aspect

**Goal:** Move `modules/home/*.nix` into `den.aspects.shared-hm` one at a time.
Same procedure as Phase 3 but for the HM side.

### Step 4.1 — Declare modules in `shared-hm` alongside `mkHost.nix`

Same approach as Phase 3: `mkHost.nix` remains the active build path. Do **not** touch
`lib/mkHost.nix` or remove anything from `modules/home/default.nix` during this phase.

### Step 4.2 — Declare modules one by one

**a)** Add to `den.aspects.shared-hm.homeManager.imports` in `parts/den.nix` (leaving `modules/home/default.nix` unchanged).
**b)** Verify with dry-run — should show no changes.

**Migration order:**

| # | File(s) | Notes |
|---|---------|-------|
| 1 | `modules/home/colorschemes/` + `modules/home/colors.nix` | Migrate together — `colors.nix` imports the colorschemes dir |
| 2 | `modules/home/git.nix` | Standalone |
| 3 | `modules/home/newsboat.nix` | Standalone |
| 4 | `modules/home/openclaw.nix` | Standalone |
| 5 | `modules/home/gtk.nix` | May read color scheme options — migrate after colors |
| 6 | `modules/home/editors.nix` | Standalone |
| 7 | `modules/home/terminals.nix` | May read color options |
| 8 | `modules/home/shell.nix` | Standalone |
| 9 | `modules/home/wm/dunst.nix` | Reads color options |
| 10 | `modules/home/wm/rofi.nix` | Reads color options |
| 11 | `modules/home/wm/swaylock.nix` | Standalone |
| 12 | `modules/home/wm/waybar.nix` | May read color options |
| 13 | `modules/home/wm/river.nix` | Standalone |
| 14 | `modules/home/wm/niri.nix` | Standalone |

> **Note on color dependencies:** Any module that reads `config.netscape.home.colors.*` must
> be migrated **after** `colors.nix`. Since all are going into the same `shared-hm` aspect,
> evaluation order within a single module list is fine — NixOS/HM module system handles it.
> The ordering above is just a safe sequence.

### Step 4.3 — (Deferred) Migrate `modules/packages/`

The package modules (`general.nix`, `development.nix`, `security.nix`, `devops.nix`,
`hardware.nix`, `ai.nix`) cannot be safely migrated during Phase 4. They fall into two
categories:

**Category A — Embedded-HM only** (`general.nix`, `development.nix`, `hardware.nix`):
These wrap all their content in `home-manager.users.netscape = { ... }`. Converting them to
pure HM modules requires removing them from `modules/packages/default.nix` simultaneously —
otherwise NixOS sees bare `home.packages` at the system level and fails. But removing them
from the active build path while Den aspects aren't yet serving the build would drop those
packages from the system. Defer to Phase 5.

**Category B — Mixed NixOS + embedded HM** (`security.nix`, `devops.nix`, `ai.nix`):
These set actual NixOS options (`programs.adb.enable`, `programs.wireshark.enable`,
`services.hermes-agent.*`, etc.) alongside HM packages. They cannot become pure HM modules
without splitting. Additionally, `ai.nix` depends on `claude-desktop` and `hermes-agent`
specialArgs which Den doesn't have until Phase 5.1 wires them in. Handle these during Phase 5
when you migrate each host: keep the NixOS options in the host's `nixos` aspect key, and put
the HM packages inline in the host's `homeManager` key.

### Step 4.4 — Migrate `hosts/Trinity.nix` and `hosts/Neo.nix`

These are pure HM modules (already use `home.packages` directly — they're imported by
`mkHost.nix` on the HM side, not the NixOS side). Inline their package lists into the Den host
aspects. **Do not** remove `hostPackages` from `parts/hosts.nix` or from `lib/mkHost.nix`
yet — `mkHost.nix` still requires it as the active build path. That removal happens in
Phase 5.7.

The host aspects in `parts/den.nix` now look like:

```nix
Trinity = {
  includes = [ den.batteries.hostname ];
  nixos.imports = [ ../hardware/Trinity.nix ];
  homeManager = { pkgs, ... }: {
    home.packages = [
      pkgs.python313Packages.impacket
    ];
  };
};

Neo = {
  includes = [ den.batteries.hostname ];
  nixos.imports = [ ../hardware/Neo.nix ];
  homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      pulsemixer acpi dmenu wl-clipboard
      unstable.claude-code
    ];
  };
};
```

> **Note on `home.stateVersion`:** `hosts/Trinity.nix` and `hosts/Neo.nix` both set
> `home.stateVersion = "22.11"`. Do not copy that line into the Den aspect — it's already
> set in `den.default.homeManager.home.stateVersion` and would conflict.

---

## Phase 5 — Replace `mkHost.nix` with Den's built-in instantiation

**Goal:** Remove `mkHost.nix` entirely. Den generates `nixosConfigurations` and
`homeConfigurations` automatically from `den.hosts` and `den.homes`. This phase wires the
remaining infrastructure (overlays, external modules, specialArgs values) into Den.

Migrate **Trinity first**, keep Neo on `mkHost.nix` until Trinity is confirmed working.

### Step 5.1 — Add global infrastructure to `den.default`

`den.default.homeManager.imports` already contains `nix-openclaw` (added in Phase 4). Add
`sops-nix`, the NixOS-side modules, and `_module.args` to replace the `specialArgs` /
`extraSpecialArgs` that `mkHost.nix` currently passes. In `parts/den.nix`:

```nix
den.default = {
  homeManager = {
    home.stateVersion          = "22.11";
    nixpkgs.config.allowUnfree = true;
    imports = [
      inputs.sops-nix.homeManagerModules.sops
      inputs.nix-openclaw.homeManagerModules.openclaw  # already present from Phase 4
    ];
    _module.args."claude-desktop" = inputs.claude-desktop;  # replaces extraSpecialArgs
  };
  nixos = {
    system.stateVersion        = lib.mkDefault "25.05";
    nixpkgs.config.allowUnfree = true;
    imports = [
      inputs.sops-nix.nixosModules.sops
      inputs.hermes-agent.nixosModules.default
    ];
    _module.args.hermes-agent = inputs.hermes-agent;  # replaces specialArgs
  };
};
```

`_module.args` injects values into every NixOS / HM module without using `specialArgs`.
After Phase 5, any module that previously took `{ claude-desktop, ... }` or
`{ hermes-agent, ... }` continues to use those same hyphenated identifiers — they are passed
via `_module.args."claude-desktop"` and `_module.args.hermes-agent` respectively, so no
module renames are required.

### Step 5.2 — Move overlays into `parts/overlays.nix`

Create `parts/overlays.nix` (auto-imported by import-tree). Leave the identical overlay
construction in `parts/hosts.nix` for now — Neo's mkHost call still needs it until Step 5.8:

```nix
{ inputs, ... }:
let
  system = "x86_64-linux";
  overlays = builtins.map (name: import (../overlays + "/${name}"))
    (builtins.filter (name: builtins.match ".*\\.nix$" name != null)
      (builtins.attrNames (builtins.readDir ../overlays)));
  unstableOverlay = final: prev: let
    unstablePkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [ "openclaw-2026.4.12" ];
      overlays = [ inputs.nix-openclaw.overlays.default ];
    };
  in {
    unstable = unstablePkgs;
    inherit (unstablePkgs) openclaw openclawPackages;
  };
in
{
  den.default.nixos.nixpkgs.overlays      = [ unstableOverlay ] ++ overlays;
  den.default.homeManager.nixpkgs.overlays = [ unstableOverlay ] ++ overlays;
}
```

Verify still clean:
```bash
nixos-rebuild dry-run --flake .#Trinity 2>&1 | grep -E "^(will|these)"
```

### Step 5.3 — Migrate deferred package modules

**This is a blocker.** `modules/packages/*.nix` are NOT in the Den aspects. When Den builds
Trinity's NixOS config it only sees what's in the aspects — so the Den-built Trinity would
be missing all packages from those files. Worse, the files use
`home-manager.users.netscape.*` (embedded HM), which is not a valid NixOS option in Den's
build (`den.schema.user.classes = []` means no home-manager NixOS module is loaded). Simply
adding them to `shared-nixos` would error. They must be converted first.

**Simple modules** (`general.nix`, `development.nix`, `hardware.nix`, `devops.nix`):

Convert each in place: strip the `home-manager.users.netscape = { ... }` wrapper so
`home.packages` is at the top level. Each becomes a pure HM module. Notes:
- `development.nix` has an inner `{ config, ... }:` lambda nested **inside** the
  `config = lib.mkIf cfg.enable { ... }` attrset. A lambda is not a valid attrset value —
  remove the inner `{ config, ... }:` and its closing `}`. The outer module arg `config`
  already refers to the HM config, so `config.programs.neovim.enable` works as-is.
- `devops.nix` uses `config.netscape.system.services.docker.enable` which is a **NixOS**
  option. Change it to `osConfig.netscape.system.services.docker.enable` and add `osConfig`
  to the module args. Also remove the unconditional `docker-compose` from the main packages
  list — it appears there as a duplicate of the entry in `lib.optionals
  osConfig.netscape.system.services.docker.enable [ docker-compose ]`. The conditional entry
  is the correct one; keep only that.

After converting, move these files from `modules/packages/` to `modules/home/packages/`
(create the subdirectory) and add them to `modules/home/default.nix`:

```nix
# modules/home/default.nix
{ imports = [
    ./colors.nix ./shell.nix ./terminals.nix ./editors.nix ./wm
    ./git.nix ./gtk.nix ./newsboat.nix ./openclaw.nix
    ./packages/general.nix
    ./packages/development.nix
    ./packages/hardware.nix
    ./packages/devops.nix
    ./packages/security.nix  # added in the security.nix step below
  ];
}
```

Because `shared-hm.homeManager.imports = [ ../modules/home ]`, Den picks these up
automatically. Because `mkHost.nix` imports `../modules/home` on the HM side, it also
picks them up. Remove only the four converted files (general, development, hardware, devops)
from `modules/packages/default.nix`. Do **not** remove `security.nix` or `ai.nix` yet —
they are handled separately below.

**`security.nix`** — mixed NixOS + HM, must split:

The `programs.adb.enable` / `programs.wireshark.enable` NixOS options add users to system
groups and must stay on the NixOS side. Add them inline to `shared-nixos.nixos.imports`
(this is the Den path for Phase 5+):

```nix
shared-nixos = {
  nixos.imports = [
    ../modules/system/secrets.nix
    # ... existing 11 entries ...
    ({ ... }: {
      programs.adb.enable       = true;
      programs.wireshark.enable = true;
    })
  ];
};
```

The HM packages section becomes `modules/home/packages/security.nix` — a pure HM module
with `home.packages = with pkgs; [ wireshark nmap ... ]`. Add it to `modules/home/default.nix`
(shown in the example above).

**Do NOT remove `security.nix` from `modules/packages/default.nix` yet.** The Den aspect's
inline NixOS block is suppressed until Step 5.6 — if `security.nix` is removed from the
mkHost path now, `programs.adb.enable` and `programs.wireshark.enable` disappear from the
running system. Instead, strip `modules/packages/security.nix` down to a NixOS-only stub
(remove the `home-manager.users.netscape` block; the HM packages now live in
`modules/home/packages/security.nix`):

```nix
# modules/packages/security.nix — NixOS stub, deleted in Step 5.8
{ config, lib, ... }:
let cfg = config.netscape.packages.security; in
{
  options.netscape.packages.security = {
    enable = lib.mkEnableOption "security and penetration testing tools" // { default = true; };
  };
  config = lib.mkIf cfg.enable {
    programs.adb.enable       = true;
    programs.wireshark.enable = true;
  };
}
```

Keep `./security.nix` in `modules/packages/default.nix`. The inline Den block and this stub
are redundant while the suppression is active; after Step 5.6 the stub becomes dead weight
and is deleted in Step 5.8.

**`ai.nix`** — mixed NixOS (Trinity-only) + HM packages + specialArgs:

`ai.nix` uses `claude-desktop` and `hermes-agent` as specialArgs and mixes
Trinity-specific NixOS service config with universal HM packages.

*HM packages* — add inline to `modules/home/default.nix` using `claude-desktop` (hyphenated,
matching both mkHost's `extraSpecialArgs` and Den's `_module.args."claude-desktop"`):

```nix
# In modules/home/default.nix, add as an inline import:
({ pkgs, claude-desktop, ... }: {
  home.packages = [
    pkgs.unstable.opencode
    pkgs.unstable.claude-code
    claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs
    pkgs.beads
    pkgs.gastown
  ];
})
```

Note: `_module.args."claude-desktop"` is set in `den.default.homeManager` (Step 5.1). The
hyphenated key must match exactly: do not use `claudeDesktop` (camelCase) here, because
`mkHost.nix` passes `claude-desktop` (hyphen) via `extraSpecialArgs` and both paths must
agree on the identifier name.

*Trinity-specific NixOS config* — `ai.nix` also sets `programs.nix-ld.enable`, the
`sops.secrets."hermes/env"` secret, the `services.hermes-agent` service, and related env
vars. These are **Trinity-only** NixOS options. They cannot be moved to the Trinity Den aspect
yet (Den aspects don't feed into mkHost until Step 5.6). The NixOS config from `ai.nix` will
be inlined into the Trinity `nixos` aspect in **Step 5.4**, alongside the other per-host
config. The full block is shown there.

**Do NOT remove `ai.nix` from `modules/packages/default.nix` yet.** The Trinity NixOS config
it contains has nowhere to land until Den builds Trinity (Step 5.6). Removing it now would
silently drop the hermes-agent service, sops secrets, and nix-ld from the mkHost Trinity
build. Remove `ai.nix` from `modules/packages/default.nix` and delete the file in **Step
5.8** when the last mkHost call is gone.

After adding the inline HM block above, the mkHost build will include the packages from both
`ai.nix` (embedded HM wrapper) and the inline block (pure HM) — a harmless duplicate until
`ai.nix` is removed in Step 5.8.

Verify the mkHost build evaluates without errors. It will show HM derivations to rebuild —
this is expected: the package modules moved from the embedded-HM NixOS path to pure HM
modules. The same packages end up in the environment; the HM generation rebuilds because the
module structure changed. No NixOS system options should have changed.

```bash
nixos-rebuild dry-run --flake .#Trinity 2>&1 | grep "^error:"
# Should produce no output
nixos-rebuild dry-run --flake .#Neo 2>&1 | grep "^error:"
# Should produce no output
```

### Step 5.4 — Expand host aspects with per-host config

In `parts/den.nix`, replace the Trinity and Neo aspects with their full configuration. The
`nixos` key changes from the attrset form (`nixos.imports = [...]`) to a function form so
that `netscape.systemName`/`netscape.hostType` (currently set by `mkHost.nix` via
`recursiveUpdate`) and the hermes-agent NixOS config can all live in one block. The
`homeManager` key merges the Phase 4 host packages with the `homeConfig` from
`parts/hosts.nix`:

```nix
den.aspects.Trinity = {
  includes = [ den.batteries.hostname den.aspects.shared-nixos ];
  nixos = { pkgs, lib, config, hermes-agent, ... }: let
    chromium-steam = pkgs.writeShellScriptBin "chromium" ''
      exec ${pkgs.steam-run}/bin/steam-run ${pkgs.chromium}/bin/chromium "$@"
    '';
  in {
    imports                                           = [ ../hardware/Trinity.nix ];
    netscape.systemName                               = "Trinity";
    netscape.hostType                                 = "desktop";
    netscape.system.networking.firewall.http.enable   = true;
    netscape.system.htb.enable                        = true;
    netscape.system.virtualisation.vmware.enable      = true;
    netscape.system.virtualisation.qemu.enable        = true;
    netscape.system.desktop.plasma.enable             = false;
    netscape.system.desktop.niri.enable               = true;
    netscape.system.services.docker.enable            = true;
    programs.nix-ld.enable                            = true;
    sops.secrets."hermes/env" = {
      sopsFile = ../secrets/secrets.yaml;
      key = "hermes/env"; mode = "0400"; owner = "root";
    };
    systemd.services.hermes-agent.environment.HERMES_OPTIONAL_SKILLS =
      "${hermes-agent}/optional-skills";
    environment.variables.HERMES_OPTIONAL_SKILLS = "${hermes-agent}/optional-skills";
    services.hermes-agent = {
      enable = true; user = "netscape"; group = "users"; createUser = false;
      extraPackages = [ chromium-steam ];
      extraDependencyGroups = [ "messaging" ];
      settings = {
        model.default = "google/gemini-2.5-flash"; model.provider = "openrouter";
        approvals.mode = "on";
        platform_toolsets.discord = [ "terminal" "file" "web" "vision" "browser"
          "skills" "todo" "cronjob" "send_message" ];
        discord = { require_mention = true; auto_thread = true; reactions = true; };
      };
      environmentFiles = [ config.sops.secrets."hermes/env".path ];
      addToSystemPackages = true;
    };
  };
  homeManager = { pkgs, ... }: {
    netscape.home.colors.enable         = true;
    netscape.home.colors.scheme         = "cyberpunk-neon";
    netscape.home.terminals.foot.enable = true;
    netscape.home.wm.niri.enable        = true;
    netscape.home.wm.waybar.enable      = true;
    netscape.home.theming.enable        = true;
  };
};

den.aspects.Neo = {
  includes = [ den.batteries.hostname den.aspects.shared-nixos ];
  nixos = { ... }: {
    imports                                         = [ ../hardware/Neo.nix ];
    netscape.systemName                             = "Neo";
    netscape.hostType                               = "laptop";
    netscape.system.networking.firewall.http.enable = true;
    netscape.system.htb.enable                      = true;
    netscape.system.virtualisation.qemu.enable      = true;
    netscape.system.services.docker.enable          = true;
  };
  homeManager = { pkgs, ... }: {
    netscape.home.wm.waybar.enable = true;
    netscape.home.theming.enable   = true;
    netscape.home.theming.gtkTheme = "Tokyonight-Dark";
    home.packages = with pkgs; [ pulsemixer acpi dmenu wl-clipboard ];
  };
};
```

> **Note on `home.packages`:** The host-specific packages added in Phase 4.4 are now
> superseded by packages arriving via `shared-hm → modules/home`:
> - `python313Packages.impacket` (Trinity): covered by `modules/home/packages/security.nix`
> - `unstable.claude-code` (Neo): covered by the inline AI block in `modules/home/default.nix`
> - `pulsemixer`, `acpi`, `dmenu`, `wl-clipboard` (Neo): these are genuinely Neo-exclusive —
>   keep them in the Neo `homeManager` key
>
> Remove the `home.packages = [ pkgs.python313Packages.impacket ]` block from the Trinity
> aspect. For Neo, remove `unstable.claude-code` from its `home.packages` list but keep the
> remaining four packages. This avoids duplicates in the Den-built home environment.

Do **not** remove `systemConfig` from the Trinity mkHost call in `parts/hosts.nix`. Den's
output suppression is still active, so the mkHost path is the live build — removing
`systemConfig` would drop those NixOS options from the running system. The mkHost call (with
`systemConfig`) is deleted in its entirety in Step 5.6.

### Step 5.5 — Wire `shared-hm` into user aspects

```nix
den.aspects.netscape-linux = {
  includes = [ den.aspects.netscape den.aspects.shared-hm ];
};
```

Verify the mkHost build is still unchanged:
```bash
nixos-rebuild dry-run --flake .#Trinity 2>&1 | grep -E "^(will|these)"
```

### Step 5.6 — Temporarily isolate Trinity in the Den topology

**Conflict:** Lifting Den's output suppression generates `nixosConfigurations.*` for every
host in `den.hosts.x86_64-linux`. Neo is still in `den.hosts` AND in `parts/hosts.nix`, so
`flake.nixosConfigurations.Neo` would be defined twice → error.

Fix: temporarily remove Neo from the Den topology while Trinity is being verified:

```nix
den.hosts.x86_64-linux = {
  Trinity.users.netscape.aspect = den.aspects.netscape-linux;
  # Neo temporarily removed — still on mkHost.nix in parts/hosts.nix
};

den.homes.x86_64-linux = {
  "netscape@Trinity".aspect = den.aspects.netscape-linux;
  # "netscape@Neo" temporarily removed
};
```

Then delete the Trinity mkHost call from `parts/hosts.nix`. And lift **both** output
suppressions (removing only `system-to-os-outputs` would leave `homeConfigurations` absent,
which breaks the Step 5.7 home verification):

```nix
den.schema.flake-system.excludes = [];  # Den generates both NixOS and HM outputs
```

### Step 5.7 — Verify Trinity

```bash
nixos-rebuild dry-run --flake .#Trinity   # Den-generated
home-manager build --flake .#"netscape@Trinity"   # Den-generated standalone HM

nixos-rebuild dry-run --flake .#Neo       # still mkHost.nix
```

Compare the Trinity system closure against Phase 4's output to confirm nothing was dropped.

### Step 5.8 — Migrate Neo and remove `mkHost.nix`

Re-add Neo to the Den topology, set up its full aspect (same process as Steps 5.4–5.7),
then:

- Delete `flake.nixosConfigurations.Neo` from `parts/hosts.nix`
- Delete `lib/mkHost.nix`, `hosts/Trinity.nix`, `hosts/Neo.nix`
- Delete `parts/hosts.nix` if empty
- Delete `modules/packages/ai.nix` and remove it from `modules/packages/default.nix` (the
  HM packages are in `modules/home/default.nix`; the Trinity NixOS config is in the Trinity
  aspect added in Step 5.4)
- Delete `modules/packages/security.nix` (the NixOS stub) — the Den `shared-nixos` inline
  block already covers `programs.adb.enable` / `programs.wireshark.enable`
- Delete `modules/packages/default.nix` entirely (nothing left to import)
- Empty `modules/system/default.nix`, `modules/home/default.nix`, and `modules/default.nix`
  — Den aspects own all imports now, so these index files are dead weight

---

## Phase 6 — Verify specialArgs elimination

`specialArgs` / `extraSpecialArgs` were eliminated in Phase 5.1 via `_module.args`. By the
time Phase 5 is complete, `lib/mkHost.nix` is deleted and no `specialArgs` remain. This
phase is a confirmation pass, not new migration work.

### Step 6.1 — Confirm no stale specialArg references

```bash
grep -r "claude-desktop\|hermes-agent" parts/ modules/ --include="*.nix"
# Should show only legitimate references (inputs.claude-desktop, inputs.hermes-agent,
# claude-desktop module arg, hermes-agent module arg) — no old specialArg patterns.
```

### Step 6.2 — Final verify

```bash
nixos-rebuild dry-run --flake .#Trinity
nixos-rebuild dry-run --flake .#Neo
home-manager build --flake .#"netscape@Trinity"
home-manager build --flake .#"netscape@Neo"
```

---

## Phase 7 — Feature-first aspect refactor

**Goal:** Split `shared-nixos` and `shared-hm` into individual feature aspects, one per concern.
This is the structural payoff of Den — each feature owns its full stack (NixOS + HM) in one
aspect. Nothing about the module contents changes; this is a reorganization.

### Step 7.1 — Extract aspects one by one

For each feature, create a new aspect and move the relevant module(s) from `shared-nixos` /
`shared-hm` into it. Update the host and user aspects to include the new one.

**Example — extracting `audio`:**

Before (in `parts/den.nix`):
```nix
den.aspects.shared-nixos = {
  nixos.imports = [ ../modules/system/audio.nix ... ];
};
den.aspects.Trinity.includes = [ den.aspects.shared-nixos ];
```

After:
```nix
den.aspects.audio = {
  nixos.imports = [ ../modules/system/audio.nix ];
};
den.aspects.shared-nixos = {
  nixos.imports = [ ... ];  # audio.nix removed
};
den.aspects.Trinity.includes = [
  den.batteries.hostname
  den.aspects.shared-nixos
  den.aspects.audio        # ← or add to a shared bundle
];
```

Or, rather than adding to every host aspect individually, keep a `shared-nixos` bundle that
itself `includes` the individual aspects:

```nix
den.aspects.shared-nixos = {
  includes = [
    den.aspects.core
    den.aspects.audio
    den.aspects.networking
    den.aspects.services
    den.aspects.security-tools
    den.aspects.virtualisation
    den.aspects.desktop
    den.aspects.packages
  ];
};
```

### Step 7.2 — Suggested aspect groupings

**NixOS-only aspects:**
| Aspect | Source modules |
|--------|---------------|
| `core` | `modules/system/core.nix` |
| `audio` | `modules/system/audio.nix` |
| `networking` | `modules/system/networking.nix` |
| `services` | `modules/system/services.nix` |
| `virtualisation` | `modules/system/virtualization.nix` |
| `security-tools` | `modules/system/htb.nix`, `modules/packages/security.nix` |
| `devops-tools` | `modules/packages/devops.nix` |
| `dev-tools` | `modules/packages/development.nix` |
| `ai-tools` | `modules/packages/ai.nix` |
| `general-packages` | `modules/packages/general.nix` |

**Cross-stack aspects (NixOS + HM in one aspect):**
| Aspect | NixOS source | HM source |
|--------|-------------|-----------|
| `desktop-niri` | `modules/system/desktop.nix` (niri parts) | `modules/home/wm/niri.nix`, `modules/home/wm/waybar.nix` |
| `desktop-plasma` | `modules/system/desktop.nix` (plasma parts) | — |
| `theming` | — | `modules/home/colors.nix`, `modules/home/colorschemes/`, `modules/home/gtk.nix` |
| `shell` | — | `modules/home/shell.nix`, `modules/home/terminals.nix` |
| `editors` | — | `modules/home/editors.nix` |
| `secrets` | `modules/system/secrets.nix` | — |

**Cross-stack example — `desktop-niri`:**
```nix
den.aspects.desktop-niri = {
  nixos = { ... }: {
    # NixOS niri service config (from desktop.nix niri section)
    programs.niri.enable = true;
    # ...
  };
  homeManager = { pkgs, ... }: {
    # HM niri + waybar config (from wm/niri.nix, wm/waybar.nix)
    programs.niri = { ... };
    programs.waybar = { ... };
  };
};
```

### Step 7.3 — Replace `hostType` conditionals

`modules/system/desktop.nix` uses `config.netscape.hostType` to set `mkDefault` values
(e.g., sway defaulting on for laptops). In Den, replace this with:

**Option A — per-host aspect includes (recommended):**
```nix
den.aspects.Trinity.includes = [
  den.aspects.shared-nixos
  den.aspects.desktop-niri    # Trinity uses niri
];

den.aspects.Neo.includes = [
  den.aspects.shared-nixos
  den.aspects.desktop-niri    # Neo also uses niri, or use desktop-sway for a different default
];
```

**Option B — parametric dispatch with a `hostData` table:**
```nix
# In parts/den.nix, add a hostData option (mirrors the reference repo)
options.hostData = lib.mkOption { type = lib.types.attrs; default = {}; };
config.hostData = {
  Trinity = { hostType = "desktop"; desktop = "niri"; };
  Neo     = { hostType = "laptop";  desktop = "niri"; };
};

den.aspects.desktop = ({ host, ... }: {
  nixos.netscape.system.desktop.niri.enable =
    config.hostData.${host.name}.desktop == "niri";
});
```

Option A is simpler and more idiomatic Den. Use it unless you have many hosts with similar
but configurable defaults.

---

## Phase 8 — Final cleanup

**Goal:** Remove all scaffolding and arrive at a clean, minimal flake.

### Step 8.1 — Consolidate directories

If `modules/` now contains only `archive/` (ignored by import-tree) and empty `default.nix`
files, delete the leftover files. If all active modules have been moved to `parts/`, rename
`parts/` to `modules/`:

```bash
mv parts/ modules/
```

Update `flake.nix`:
```nix
outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
  (inputs.import-tree ./modules);
```

### Step 8.2 — Remove `flake-utils`

`flake-utils` was used only for `devShells.${system}`. `flake-parts`'s `perSystem` replaces
this. Remove `flake-utils` from inputs and from any `inputs.*.follows` references
(e.g., `claude-desktop` pins it — check if removing the follow breaks the build):

```bash
nix flake check 2>&1 | grep flake-utils
```

If `claude-desktop` still requires it, keep the input but remove the `follows` so it uses
its own pinned version.

### Step 8.3 — Remove empty `default.nix` files

`import-tree` discovers files automatically. Any `default.nix` that only contains
`{ imports = []; }` or `{ imports = [ ./a ./b ]; }` is now redundant:

```bash
find . -name "default.nix" -not -path "./.git/*" | xargs grep -l "imports"
```

Review each one — only delete if import-tree already covers it.

### Step 8.4 — Final verification

```bash
nix flake check          # runs alejandra + statix (pre-commit hooks)
nixos-rebuild dry-run --flake .#Trinity
nixos-rebuild dry-run --flake .#Neo
home-manager build --flake .#"netscape@Trinity"
home-manager build --flake .#"netscape@Neo"
```

---

## Summary

| Phase | What Changes | Key Files | Risk |
|-------|-------------|-----------|------|
| 1 | `flake.nix` → flake-parts wrapper | `flake.nix`, new `parts/` | Very low |
| 2 | Add Den, declare topology (builds unchanged) | `parts/den.nix` | Very low |
| 3 | System modules declared in `shared-nixos` aspect | `parts/den.nix` only — `modules/system/` untouched | Low per module |
| 4 | HM modules declared in `shared-hm` aspect | `parts/den.nix` only — `modules/home/` untouched | Low per module |
| 5 | Replace `mkHost.nix` with Den instantiation; convert package modules; resolve specialArgs via `_module.args` | `lib/mkHost.nix` deleted, `parts/hosts.nix`, `parts/den.nix`, `modules/home/` | Medium — do Trinity first |
| 6 | Verify specialArgs elimination (no new work — done in 5.1) | grep pass only | Very low |
| 7 | Feature-first aspect split | `parts/den.nix` | Low per split |
| 8 | Rename, clean up, final check | `flake.nix`, empty files | Very low |

**The invariant through Phases 1–4:** `mkHost.nix` remains the active build path. Den aspects
are assembled alongside it but not yet used for building. You can stop at the end of any phase
and have a fully functional config. Phase 5 is the only phase with a hard cutover — do Trinity
first, and keep a `git stash` or branch as a rollback point.
