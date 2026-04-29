# v43 Steam Deck Wayland/X11 Solution Plan (Overlay-Focused)

## Problem

- Batocera v42 introduced `VariableRefresh true` in the amdgpu Xorg config, causing persistent screen tearing on Steam Deck (AMD Van Gogh) X11 builds. Exhaustive testing (13 driver/kernel-param combos, TearFree, vblank_mode, Mesa VK present mode) failed to resolve it on v42/v43 X11.
- Batocera v43 Steam Deck will use Wayland by default for HD Mode, which eliminates the X11 tearing issue for HD use.
- CRT Mode requires X11 (switchres, 15 kHz, xrandr).
- The CRT Script currently assumes X11 and breaks on Wayland builds.
- The dual-boot approach solves both problems: Wayland for HD (no tearing), X11 for CRT (switchres/xrandr).

## Why Overlay is the Best Option

The Mode Switcher already uses overlay file swap (`/boot/boot/overlay`) between HD and CRT modes. The overlay is a squashfs image that holds all system-level changes (files in `/etc/`, `/usr/`, etc.). One file swap at boot time = complete display-stack switch. Benefits:

- **Atomic:** Single overlay swap replaces many individual file edits.
- **Proven:** `backup_overlay_file` and `restore_overlay_file` in `03_backup_restore.sh` already implement this.
- **Clean:** HD overlay = Wayland configs; CRT overlay = X11 configs; no mixed state.

## Critical Constraint: Build Dependencies

switchres is not built for Wayland images (Config.in line 768: `!BR2_PACKAGE_BATOCERA_WAYLAND`). If the v43 Steam Deck image is a pure Wayland build, switchres (and likely full X11) will not be present. The overlay can only swap *what exists on the system*.

**Assumption for this plan:** The v43 Steam Deck build either (a) remains X11, or (b) includes both Wayland and X11/switchres (e.g. via XWayland plus optional native X11). Validation is required on the actual v43 Steam Deck image.

## Architecture (Overlay-Based)

```
flowchart TB
    subgraph Boot
        BootInit[Boot]
        CheckOverlay{/boot/boot/overlay exists?}
        HDStack[Wayland: sway/labwc + ES]
        CRTStack[X11: startx + switchres + ES]
    end
    BootInit --> CheckOverlay
    CheckOverlay -->|No or HD overlay| HDStack
    CheckOverlay -->|CRT overlay| CRTStack
```

- **HD Mode:** Overlay absent or contains Wayland-friendly state → system uses sway-launch/labwc-launch.
- **CRT Mode:** Overlay contains X11 stack overrides → system uses startx with CRT configs (xinitrc, 20-modesetting, boot-custom.sh, etc.).

## Implementation Approach

### Phase 1: Wayland Build Detection

Early in `Batocera-CRT-Script-v43.sh`, detect whether the build is Wayland:
- e.g. check `/usr/bin/sway-launch` or `/usr/bin/labwc-launch` and whether emulationstation-standalone launches them.
- If Wayland, follow the Overlay + Install path below.
- If X11, keep current flow (no display-server swap).

### Phase 2: First-Run Install (Wayland Build)

When the user runs the CRT Script on a fresh v43 Steam Deck (Wayland):

1. **Backup HD state**
   - Run `backup_overlay_file "hd"` (or equivalent) to save the current overlay (or "no overlay") to `.../hd_mode/overlay/overlay.hd`.

2. **Create CRT overlay**
   The CRT script must produce an overlay that:
   - Overrides `/etc/init.d/S31emulationstation` to use startx instead of sway-launch/labwc-launch.
   - Overrides `/usr/bin/emulationstation-standalone` to use startx (or ensure S31emulationstation drives the change).
   - Includes X11 configs: xinitrc, 20-modesetting.conf, boot-custom.sh, etc.
   - Uses `batocera-save-overlay` to persist these changes into the active overlay.

3. **Backup CRT overlay**
   - Run `backup_overlay_file "crt"` to store the newly created overlay.

4. **Reboot**
   - System boots with CRT overlay active → X11 + switchres.

### Phase 3: Mode Switcher Extension

Extend `03_backup_restore.sh`:
- **HD → CRT:** Restore CRT overlay (existing logic).
- **CRT → HD:** Restore HD overlay or remove overlay (existing logic).
- Ensure overlay restore runs before other restores (already the case: "RESTORE OVERLAY FILE FIRST").

### Phase 4: CRT Script Install Flow (v43, Wayland)

Adjust `Batocera-CRT-Script-v43.sh` to:
- Detect Wayland build.
- **If Wayland:**
  1. Backup HD overlay first (before any CRT changes).
  2. Apply CRT changes (X11 configs, init overrides) so they land in the live overlay.
  3. Run `batocera-save-overlay`.
  4. Backup CRT overlay.
  5. Reboot.
- **If X11:** keep current behavior.

## Step-by-Step User Journey

### Journey A: Fresh v43 Steam Deck (Wayland) – First-Time CRT Install

| Step | User action | System behavior |
|------|-------------|-----------------|
| 1 | Flash Batocera v43 Steam Deck image | Boots to HD Mode (Wayland). |
| 2 | Run Batocera-CRT-Script (install) | Script detects Wayland build. |
| 3 | User completes CRT setup (monitor, outputs, etc.) | Script backs up HD overlay. |
| 4 | Script applies CRT changes | X11 configs written; init overrides installed; batocera-save-overlay runs. |
| 5 | Script backs up CRT overlay and reboots | Reboot with CRT overlay active. |
| 6 | System boots | X11 + switchres; CRT Mode active. |

### Journey B: CRT → HD (Mode Switcher)

| Step | User action | System behavior |
|------|-------------|-----------------|
| 1 | From CRT Mode, open Mode Switcher (CRT Tools) | Mode Switcher UI loads. |
| 2 | Choose "Switch to HD Mode" | Backup current (CRT) overlay; restore HD overlay (or remove overlay). |
| 3 | Confirm and reboot | Reboot. |
| 4 | System boots | Wayland HD Mode. |

### Journey C: HD → CRT (Mode Switcher)

| Step | User action | System behavior |
|------|-------------|-----------------|
| 1 | From HD Mode, open Mode Switcher | Mode Switcher UI loads. |
| 2 | Choose "Switch to CRT Mode" | Backup current (HD) overlay; restore CRT overlay. |
| 3 | Confirm and reboot | Reboot. |
| 4 | System boots | X11 CRT Mode. |

## Files to Touch

| File | Change |
|------|--------|
| `docs/v42-steam-deck-screen-tearing-summary.md` | Add "v43 Wayland Solution (Overlay)" section with this plan and user journeys. |
| `Batocera-CRT-Script-v43.sh` | Wayland detection; HD overlay backup before CRT changes; init override logic for Wayland build. |
| `03_backup_restore.sh` | Ensure overlay swap handles Wayland HD overlay correctly (remove vs restore). |

## Pre-Built Overlay Option (Alternative)

If creating a CRT overlay at install time is fragile, consider shipping a pre-built CRT overlay in the script package. On Wayland install:
1. Copy pre-built overlay to `/boot/boot/overlay`.
2. Back it up as CRT overlay.
3. Back up current (HD) overlay as HD overlay.
4. Reboot.

*[Inference] This assumes the base image has X11 and switchres. If it does not, a pre-built overlay cannot add them.*

## Validation Checklist

- [ ] Confirm v43 Steam Deck image: Wayland-only vs X11 vs hybrid (Wayland + X11/switchres).
- [ ] If Wayland-only: Document limitation or pursue upstream to include X11/switchres for CRT.
- [ ] Test overlay backup/restore on v43 Steam Deck.
- [ ] Test S31emulationstation override (startx vs sway-launch) via overlay.
- [ ] Test Mode Switcher CRT ↔ HD on v43 Steam Deck.

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

