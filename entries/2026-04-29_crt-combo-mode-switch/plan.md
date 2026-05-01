# CRT Combo Mode Switch (Controller Combo to Switch CRT → HD)

> **KB convention:** `plan.md` is the **session-start** implementation plan (first intent). **`VERDICT.md`** records **plan vs reality** after development (how far shipped work diverged). See repository **`README.md`** → **VERDICT.md**. Late discoveries belong in **`design/`** and **`VERDICT.md`**, not by rewriting this file to match reality.

## Problem

When a handheld running CRT Mode is powered on without a CRT display attached (e.g. traveling, forgot to switch to HD Mode before leaving), the user gets a **permanent black screen**. The 15kHz CRT output cannot drive the handheld's built-in LCD. There is no way to switch to HD Mode without SSH access or plugging into a CRT.

This is a dead end for non-technical users and a frustration for everyone.

## User Journey

### The problem scenario

1. User has a handheld (Steam Deck, Retroid, AYN, etc.) with CRT Script installed
2. At home, they use CRT Mode with a CRT display
3. They need to leave (train, trip, couch) and forget to switch to HD Mode first
4. They power on the handheld away from home
5. **Black screen.** The system boots into CRT Mode, outputs 15kHz, the LCD shows nothing
6. Currently: the device is a brick until they get back to a CRT or SSH in

### The solution scenario

1. Same setup: handheld powers on, black screen (CRT Mode, no CRT attached)
2. User holds **SELECT + START + L1 + L2 + R1 + R2** for 5 seconds
3. A short **controller vibration** (force feedback) confirms the combo was detected and the switch is starting
4. System automatically switches to HD Mode using previously saved HD settings
5. System reboots (or powers off for dual-boot)
6. Device boots into HD Mode, LCD works, user can play

### Key UX details

- **No timing required.** Triggerhappy (`thd`) runs as `S50triggerhappy` from early boot, well before EmulationStation. The combo is active as soon as `thd` starts. The user can press the combo at any point: during boot, at the ES menu, or minutes after boot.
- **5-second hold requirement.** The triggered script sleeps 5 seconds before acting. This prevents accidental activation and gives the user confidence the system registered their intent. The 6-button chord itself is essentially impossible to hit during normal use.
- **Blind-friendly.** The user has no screen. Feedback is **haptic**: a brief rumble on the gamepad to confirm "switching now." No audio beep (silent in public or when speakers are off).
- **No-op safety.** If the system is already in HD Mode, the script exits silently. If HD settings have never been saved (no prior mode switch), the script exits silently.
- **Does not interfere with gameplay.** The 6-button combo is impossible to hit during normal use. No game or menu maps all 6 of these buttons simultaneously.

## Root Cause

No mechanism exists to switch modes without a display. The mode switcher (`mode_switcher.sh`) is a dialog-based interactive tool that requires a visible terminal.

## Solution

Uses triggerhappy (`multimedia_keys.conf`) and a shell script. This follows the **exact same pattern** the CRT Script already uses for RIGHTALT+F1/F2/F3 shortcuts. No Python. No new daemons. Vibration feedback (best-effort; not all controllers support force feedback).

### 1. Triggerhappy entry (`multimedia_keys.conf`)

One new line added to the CRT Script's existing `multimedia_keys.conf`:

```
BTN_SELECT+BTN_START+BTN_TL+BTN_TR+BTN_TL2+BTN_TR2  1  /usr/bin/crt-mode-switch-combo
```

Triggerhappy supports up to 5 modifiers per event (1 primary + 5 modifiers = 6 buttons total). It already handles `BTN_*` gamepad codes on handhelds (GameForce Chi, ODROID GO, etc. use `BTN_TRIGGER_HAPPY*` combos in upstream Batocera).

### 2. Combo handler script (`crt-mode-switch-combo`)

Small shell script installed to `/usr/bin/` (same as `esrestart`, `xrestart`, `emukill`):

1. Sleep 5 seconds (hold requirement; the 6-button chord already prevents accidental triggers)
2. Source mode switcher modules (`01_mode_detection.sh`, `03_backup_restore.sh`)
3. Check current mode is CRT (no-op if HD)
4. Check HD backup exists (no-op if missing)
5. Short **rumble** (force feedback) to confirm the switch is proceeding (best-effort; no-op if controller lacks `EV_FF`)
6. `backup_mode_files "crt"` + `restore_mode_files "hd"`
7. Mirror the pre-reboot `es_systems_crt.cfg` copy/touch/sync block from `mode_switcher.sh` so behavior matches the UI path
8. `sync`
9. `poweroff` (dual-boot) or `reboot` (single-boot)

### 3. Headless mode switch logic (in the combo handler or a separate `mode_switch_headless.sh`)

Sources the existing mode switcher modules (`01_mode_detection.sh`, `03_backup_restore.sh`), sets the same globals as `mode_switcher.sh`, and runs the non-interactive backup/restore/reboot path.

### Integration

Deployed identically to existing multimedia keys:
- `multimedia_keys.conf` updated with the new line
- `crt-mode-switch-combo` copied to `/usr/bin/` and `chmod 755`
- Done in the **v43** ALLINONE installer, same block as `esrestart`/`xrestart`/`emukill`
- No changes to `boot-custom.sh`
- No new daemons or services
- Triggerhappy picks up the config automatically (already reads `/userdata/system/configs/multimedia_keys.conf`)

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `extra/media_keys/multimedia_keys.conf` | Add BTN combo line |
| Batocera-CRT-Script | `extra/media_keys/crt-mode-switch-combo` | New: combo handler script |
| Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` | Modified: deploy new script during install |

## Git (commits)

When committing `crt-mode-switch-combo`, record the executable bit in the index so clones and PRs keep `755`:

```bash
git add --chmod=+x -- path/to/extra/media_keys/crt-mode-switch-combo
```

If the file is already staged without the bit, either re-add with `--chmod=+x` or:

```bash
git update-index --chmod=+x path/to/extra/media_keys/crt-mode-switch-combo
```

(Adjust the path to match the repo layout, e.g. under `userdata/system/Batocera-CRT-Script/extra/media_keys/` in this workspace.)

## Validation

- [ ] Triggerhappy detects the 6-button combo on a handheld controller
- [ ] Correct `BTN_*` codes confirmed via `evtest` on target hardware
- [ ] 5-second sleep provides adequate accidental-trigger protection
- [ ] No false triggers during normal ES navigation or gameplay
- [ ] Headless mode switch correctly restores HD settings from backup
- [ ] System reboots into working HD Mode after combo trigger
- [ ] No-op when already in HD Mode
- [ ] No-op when HD settings backup doesn't exist
- [ ] Vibration feedback works on target hardware (best-effort; switch proceeds even without it)
- [ ] L2/R2 trigger as BTN_TL2/BTN_TR2 on target controllers (not analog-only axes)

## Open Questions

- **HD backup predicate:** `restore_mode_files hd` may behave differently for an empty `hd_mode` tree vs missing backup (see `03_backup_restore.sh`). Decide strict “user must have switched once” vs permissive match to `restore_mode_files` success; document in script header.
- **BTN_SELECT vs BTN_BACK:** Some controllers report SELECT as `BTN_SELECT`, others as `BTN_BACK`. Need `evtest` on target hardware to confirm.
- **L2/R2 as analog axes:** If the target controller reports L2/R2 as `ABS_Z`/`ABS_RZ` (analog axes) instead of `BTN_TL2`/`BTN_TR2` (digital buttons), triggerhappy cannot detect them (it handles `EV_KEY` events, not `EV_ABS`). May need to adjust the combo to use different buttons, or fall back to the Python listener approach (see Backup section).
- **Modifier order:** Triggerhappy requires the modifier buttons to be held when the primary event fires. The order in the config line matters. May need testing to find which button should be "primary" (the last one pressed).

---

## Backup Approach: Python evdev Combo Listener

If triggerhappy cannot reliably detect the combo (e.g. L2/R2 are analog-only on target hardware, or the 5-modifier limit is hit differently than documented), fall back to a custom Python listener daemon.

### Components

**1. Combo listener daemon (`crt_combo_listener.py`)**

- Python script using `evdev` + `pyudev` (both already in Batocera image)
- Runs as a persistent background daemon from early boot (`S00bootcustom` / `boot-custom.sh`) with `&` to background
- Passively reads (no grab) all controller evdev devices
- Tracks button state per device; when all 6 target buttons are held for 5 continuous seconds, triggers the switch
- Handles both digital buttons (`EV_KEY`) and analog triggers (`EV_ABS` with threshold)
- Provides haptic feedback on activation (same as primary path: vibration; optional audio only if ever added)
- Near-zero CPU when idle (blocks on `poll()`)
- Exits cleanly on SIGTERM

**2. Headless mode switch script (`mode_switch_headless.sh`)**

Same as the primary approach: sources modules, runs backup/restore, reboots.

### Why this is backup (not primary)

- Adds a Python dependency where the rest of the CRT Script is pure shell
- Requires a new persistent daemon (more moving parts)
- Needs integration with `boot-custom.sh` (which is already complex and mode-dependent)
- Does not follow established CRT Script patterns (`multimedia_keys.conf` is the existing pattern)

### When to use backup

- Target controller reports L2/R2 as analog-only axes (no `BTN_TL2`/`BTN_TR2`)
- Triggerhappy's modifier limit prevents reliable 6-button detection
- Need finer control over hold timing (exact 5-second window with cancel-on-release)

### Backup Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Geometry_modeline/crt_combo_listener.py` | New: combo listener daemon |
| Batocera-CRT-Script | `Geometry_modeline/mode_switch_headless.sh` | New: non-interactive CRT→HD switch |
| Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` | Modified: deploy new files during install |
| Boot partition | `/boot/boot-custom.sh` | Modified: start combo listener daemon in background |

---

## Appendix (2026-05-01): Operator reference (post-ship)

Do not rewrite the plan body above; this appendix points at shipped behavior and ops docs.

| Topic | Where |
|--------|--------|
| Optional **`crt-mode-switch-combo.debug`** dry-run (haptic only, no HD restore, no shutdown) | **`debug/02-crt-mode-switch-combo-debug-operator.md`** |
| Plan vs shipped narrative | **`VERDICT.md`** |
| Deck watcher, logging, why not only triggerhappy | **`design/README.md`** |

**First-time user requirement:** blind CRT→HD restore requires a prior **HD mode backup** from the UI switcher (`hd_mode/mode_metadata.txt` with **`MODE=hd`**). Otherwise the combo exits after guards with a log line (no bricking restore).
