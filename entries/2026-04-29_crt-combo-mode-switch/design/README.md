# Design — CRT Combo Mode Switch

This document matches **shipped behavior** in Batocera-CRT-Script (v43 ALLINONE media-keys block) as of **2026-05**. Historical triggerhappy-only intent lives in **`plan.md`** (first draft).

---

## Shipped architecture (two input paths)

| Path | When | Input | Handler |
|------|------|--------|---------|
| **A. Triggerhappy** | Boards where **`thd`** multi-`BTN_*` chords work | **`S50triggerhappy`** + **`multimedia_keys.conf`** | **`/usr/bin/crt-mode-switch-combo`** (bash) |
| **B. Deck watcher** | **Steam Deck** (triggerhappy unreliable for this chord) | Batocera user service **`crt_mode_switch_watcher`** → **`crt-mode-switch-watcher.py`** | Spawns **`/bin/bash`** on **`crt-mode-switch-combo`** (same script as A) |

Both paths end at the **same** **`crt-mode-switch-combo`** script. **`boot-custom.sh`** is **unchanged** for this feature (no persistent **`crt_combo_listener.py`** in the shipped Deck path).

### Deck path (diagram)

```
crt_mode_switch_watcher (userdata/system/services)
  └── python3 crt-mode-switch-watcher.py
         ├── find one gamepad evdev node (name rank: "Steam Deck",
         │     then "Valve Software Steam Deck Controller", etc.; skip Motion/Mouse/Virtual)
         ├── require all chord keys in EV_KEY caps
         ├── read_loop: SELECT+START+L1+L2 all down → spawn once (armed edge)
         └── Popen: /bin/bash <combo>  (start_new_session; stdio to /dev/null)

crt-mode-switch-combo (bash)
  ├── flock on /tmp/crt-mode-switch-combo.lock (before blind sleep)
  ├── sleep 5
  ├── embedded python3: FF_RUMBLE (effect.u.ff_rumble_effect), then hidraw 0xEB fallback (Deck HID uevent)
  ├── if /userdata/system/crt-mode-switch-combo.debug exists → exit 0 (haptic-only QA)
  ├── guards (CRT install marker, CRT mode, HD backup metadata MODE=hd)
  ├── backup_mode_files "crt" / restore_mode_files "hd"
  ├── es_systems_crt.cfg mirror + sync (same idea as mode_switcher.sh)
  ├── sleep 2
  └── is_dualboot_system? → /sbin/poweroff else /sbin/reboot (+ shutdown fallbacks; PATH may lack /sbin)
```

### Triggerhappy path (diagram, when used)

```
S50triggerhappy → multimedia_keys.conf
  └── optional BTN_* lines (six-primary pattern or fewer) → bash crt-mode-switch-combo
```

**Deck `multimedia_keys.conf`:** chord is **not** implemented as **`BTN_*`** lines (commented / documented there); Deck uses the watcher instead.

---

## Why Python for the Deck watcher (not “just shell”)

The **CRT → HD blind switch** logic (backup, restore, shutdown) lives in **bash** (`crt-mode-switch-combo`), sourcing **`01_mode_detection.sh`** / **`03_backup_restore.sh`** like the UI mode switcher. Only **how we detect the chord on Deck** differs.

### What we tried first: triggerhappy (`thd`) + shell

**triggerhappy** is ideal where it works: **no extra long-lived process**, same pattern as **`esrestart`** / **`xrestart`**.

On **Steam Deck**, **`thd`** proved **unreliable** for this multi-button chord: it listens across **`/dev/input/event*`** and chord rules use **`mods_equal`**-style matching. Extra held keys from **other nodes** can block the rule even when the physical chord is correct. Fixing that inside triggerhappy means fighting **global** input state, not adding one more config line.

### Why not a pure shell script reading `/dev/input`?

**evdev** is a binary **`struct input_event`** stream. A correct reader must open the right **`eventN`**, read in a loop, track **key state**, and handle errors / replug. That is **not** a few lines of portable **`sh`** without a helper binary. Implementations end up as **C**, **Python `evdev`**, or similar.

### What Python buys here (narrow scope)

1. **`python3` + `evdev`** are already on the Batocera image (same family as combo haptics).
2. **`crt-mode-switch-watcher.py`** opens **one** ranked gamepad node, tracks **four** `EV_KEY` codes (`BTN_SELECT`, `BTN_START`, `BTN_TL`, `BTN_TL2`), **no grab**, then **spawns the bash combo**. No duplicate restore logic in Python.
3. Combo haptics use embedded **`python3`** with **`FF_RUMBLE`**; on Batocera **`Effect`** uses **`effect.u.ff_rumble_effect`** (not **`effect.u.rumble`**).

**Summary for leads:** Bash remains **source of truth** for mode files and **shutdown**. Python is only **device-scoped evdev** where **triggerhappy’s global chord model** is the wrong tool.

---

## Combo handler flow (`crt-mode-switch-combo`) — shipped order

1. **`flock`** single-instance lock **before** `sleep 5` (parallel chord spawns must not each sleep then clobber state).
2. **`sleep 5`** blind hold window (chord detection is separate: watcher or `thd` fires the script).
3. **Haptics:** embedded Python scans `event*` (prefer name **`Steam Deck`**), **`FF_RUMBLE`** via **`ff_rumble_effect`**; hidraw **`0xEB`** fallback for Valve/Deck HID uevent gamepad nodes.
4. **Optional:** if **`/userdata/system/crt-mode-switch-combo.debug`** exists → log and **exit 0** (no restore, no shutdown). Installer does **not** create this file.
5. Guards: **`check_crt_script_installed`**, **`detect_current_mode`** == crt, HD backup predicate (**`mode_metadata.txt`** **`MODE=hd`**).
6. **`backup_mode_files "crt"`**, **`restore_mode_files "hd"`**, **`es_systems_crt.cfg`** copy/touch/sync block, **`sleep 2`**.
7. **`/sbin/poweroff`** (dual-boot: `/boot/crt/linux` + `initrd-crt.gz`) or **`/sbin/reboot`** / **`shutdown`** fallbacks.

---

## Target buttons — Steam Deck (shipped chord)

| Logical | evdev |
|---------|--------|
| SELECT | `BTN_SELECT` |
| START | `BTN_START` |
| L1 | `BTN_TL` |
| L2 | `BTN_TL2` |

**R1/R2** are **not** part of the shipped Deck chord (reduces accidental overlap with **`thd`** modifier issues). Other handhelds may still use a **six-button** **`BTN_*`** **`multimedia_keys.conf`** pattern where **`thd`** works; see **`plan.md`** and optional lines below.

---

## Multimedia keys (`multimedia_keys.conf`)

**Shipped Deck-oriented file:** documents that the blind chord is handled by **`crt_mode_switch_watcher`**; **do not** duplicate as **`BTN_*`** lines for Deck.

**Optional six-line triggerhappy pattern** (for hardware where all six keys work with `thd`): each line uses a different **primary** key so keydown order does not miss the chord (see `triggerparser.c`: first token is primary; up to five modifiers).

```
BTN_SELECT+BTN_START+BTN_TL+BTN_TR+BTN_TL2+BTN_TR2  1  bash /usr/bin/crt-mode-switch-combo
BTN_START+BTN_SELECT+BTN_TL+BTN_TR+BTN_TL2+BTN_TR2  1  bash /usr/bin/crt-mode-switch-combo
BTN_TL+BTN_SELECT+BTN_START+BTN_TR+BTN_TL2+BTN_TR2  1  bash /usr/bin/crt-mode-switch-combo
BTN_TR+BTN_SELECT+BTN_START+BTN_TL+BTN_TL2+BTN_TR2  1  bash /usr/bin/crt-mode-switch-combo
BTN_TL2+BTN_SELECT+BTN_START+BTN_TL+BTN_TR+BTN_TR2  1  bash /usr/bin/crt-mode-switch-combo
BTN_TR2+BTN_SELECT+BTN_START+BTN_TL+BTN_TR+BTN_TL2  1  bash /usr/bin/crt-mode-switch-combo
```

**L2/R2 concern (triggerhappy path only):** if L2/R2 are **analog axes** only, `thd` will not see them; use a different chord or a heavier Python listener (backup design below).

---

## Feedback mechanism (haptics)

- **In combo, after the 5s sleep:** best-effort **`FF_RUMBLE`**; switch still runs if rumble fails.
- **Not audio** in the default flow.
- Deck **`evtest`** node for rumble is often named **`Steam Deck`** with **`FF_RUMBLE`**; python-evdev must use **`ff_rumble_effect`** on current Batocera.

---

## Safety considerations

1. **Four-button chord on Deck** (still awkward in normal play); **5s** sleep adds margin.
2. **CRT-only:** combo exits if not CRT mode.
3. **HD backup required:** guard prevents restoring without a prior UI HD save (`MODE=hd`).
4. **No grab** in the Deck watcher; games/ES keep input.
5. **CRT → HD** direction only from this chord; HD → CRT remains the UI mode switcher.

---

## Logging / persistence

- **`/userdata/system/logs/crt-script-mode-switch.log`**: combo + watcher (and mirrored legacy **`crt-mode-switch-watcher.log`** for combo lines via combo’s `_crt_script_log`).
- Installer copies **`crt-mode-switch-combo`** and **`crt-mode-switch-watcher.py`** to **`/usr/bin`** and mirrors into **`userdata/.../extra/media_keys/`** so updates survive without overlay.

---

## Backup design: persistent Python listener (not shipped on Deck)

**Reserved** if a board needs **multi-device** enumeration, **analog triggers**, or **`boot-custom.sh`** integration. **Not** the same component as **`crt-mode-switch-watcher.py`** (single node, four keys, spawn bash).

### Architecture (backup)

```
S00bootcustom ─── boot-custom.sh
       │                 ├── (existing CRT tasks)
       │                 └── crt_combo_listener.py &
       ▼                          │
  (system running)         ┌──────┴──────┐
                           │ persistent │
                           │ poll evdev │
                           │ 6-btn + 5s │
                           └──────┬──────┘
                                  ▼
                         mode_switch_headless.sh (historical name)
```

### Combo listener flow (backup)

```
START → enumerate event* → poll → EV_KEY / optional ABS thresholds
     → all 6 held ≥ 5s → FF_RUMBLE → exec headless switch script
```

### Target buttons — evdev mapping (backup)

| Logical | evdev typical | Notes |
|---------|---------------|--------|
| SELECT | BTN_SELECT / BTN_BACK | varies |
| START | BTN_START / BTN_FORWARD | varies |
| L1 | BTN_TL | |
| R1 | BTN_TR | |
| L2 | BTN_TL2 or ABS_Z | analog-only needs listener logic |
| R2 | BTN_TR2 or ABS_RZ | |

### Controller rumble (backup snippet)

```python
import evdev
device.write(evdev.ecodes.EV_FF, effect_id, 1)
```

On Batocera, prefer the same **`ff_rumble_effect`** field usage as the shipped combo haptic block.

---

## Watcher toggle UI (planned, 2026-05-05)

Add a dedicated **"Blind Switch Watcher"** page to the mode switcher dialog, reachable from the **main menu** and the **config summary** (`EDIT_WATCHER`).

### Gate

Same predicate as `crt-mode-switch-combo` guard #3:

```bash
_hd_backup_exists() {
  local meta="/userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/mode_metadata.txt"
  [ -f "$meta" ] && grep -q '^MODE=hd' "$meta" 2>/dev/null
}
```

### Service control

```bash
_watcher_enabled() {
  local svcs
  svcs="$(batocera-settings-get system.services 2>/dev/null)"
  echo " $svcs " | grep -q ' crt_mode_switch_watcher '
}
```

- **Enable:** `batocera-services enable crt_mode_switch_watcher && batocera-services start crt_mode_switch_watcher`
- **Disable:** `batocera-services stop crt_mode_switch_watcher && batocera-services disable crt_mode_switch_watcher`

No reboot; acts immediately.

### Page states

| State | Condition | Action rows |
|-------|-----------|-------------|
| UNAVAILABLE | `_hd_backup_exists` false | Only BACK (info-only) |
| OFF | HD backup exists, service not in `system.services` | ENABLE + BACK |
| ON | HD backup exists, service in `system.services` | DISABLE + BACK |

### Dialog prompt text (shipped in `show_watcher_page`)

```
WHAT THIS DOES
Recommended for handheld devices, this enables a background
service that watches for a held button combo. When detected,
it switches from CRT Mode to HD Mode without needing a
display. Useful when you power on away from a CRT and get a
black screen.

BUTTON COMBO
Hold SELECT + START + L1 + L2 for 5 seconds.
A brief controller rumble confirms the switch right before
the system reboots into HD Mode.

PREREQUISITES
You must complete one full HD/CRT round trip using the mode
switcher first (CRT -> HD -> CRT). This saves the HD settings
that the blind switch restores.

Status: [ON / OFF / UNAVAILABLE (complete one HD/CRT round trip to unlock)]
```

### Config summary page

The "Mode Switch Configuration" summary page shows status in the **info block at the top** (alongside HD Output, CRT Output, CRT Boot):

```
Blind Switch Watcher: ON
```
or `OFF` or `UNAVAILABLE`.

The menu row below is just the edit action:

```
EDIT_WATCHER   Edit Blind Switch Watcher
```

### Installer default

ALLINONE v43 deploys the service file but does **not** auto-enable. User opts in via this toggle (or `batocera-services enable crt_mode_switch_watcher` manually).
