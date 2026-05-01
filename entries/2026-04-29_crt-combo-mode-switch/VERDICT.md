# VERDICT — CRT Combo Mode Switch

## Status

In progress — **PR [#413](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/413)** OPEN (`key-combo-mode-switch` → `main`). Merge state: **`pr-status.md`**.

## Summary

**Original plan (`plan.md`):** triggerhappy only + **`crt-mode-switch-combo`** (bash). Explicitly **no Python listener**, **no new daemons**, **`boot-custom.sh`** unchanged.

**Shipped reality (so far):** the **bash combo** is the core switch path and still sources **`01_mode_detection.sh`** / **`03_backup_restore.sh`**. On **Steam Deck**, **triggerhappy** proved unreliable for multi-button chords (global **`event*`** / **`mods_equal`** behavior), so a **narrow Python + evdev watcher** (**`crt-mode-switch-watcher.py`**) runs under Batocera **`crt_mode_switch_watcher`** user service, binds **one** ranked gamepad node (e.g. **`Steam Deck`**, **`Valve Software Steam Deck Controller`**; excludes Motion/Mouse/Virtual), chord **SELECT+START+L1+L2**, and spawns the **same bash combo**. That is **not** the heavy **`boot-custom.sh`** multi-device backup daemon from **`plan.md`** backup section; it is a **Deck-specific input adapter**. Canonical flow and diagrams: **`design/README.md`**.

Additional hardening: **userdata** copies of combo + watcher, **unified logging** under **`/userdata/system/logs/crt-script-mode-switch.log`**, installer mirror from **`/usr/bin`** into **`extra/media_keys/`** where applicable (overlay-free persistence). Some **`multimedia_keys.conf`** **`BTN_*`** lines may be omitted or commented for Deck where **`thd`** is not used for this chord.

## Plan vs reality

| Topic | `plan.md` (first intent) | Reality |
|--------|--------------------------|---------|
| Input path | **`S50` triggerhappy** + **`multimedia_keys.conf`** | **Deck:** **`crt_mode_switch_watcher`** + Python **`evdev`**; **others:** **`thd`** where it works |
| Python | “No Python” (except optional one-shot rumble in combo) | **Persistent small Python process** on Deck for **input only**; combo remains bash |
| Daemons / services | “No new daemons” | **`crt_mode_switch_watcher`** user service (not **`boot-custom.sh`**) |
| Chord | Six-button **`BTN_*`** hold | **Deck:** **Select + Start + L1 + L2** (four keys); **`crt_mode_switch_watcher`** |
| Logging | (not specified in original plan) | **CRT-script log** on **`/userdata`** for combo + watcher |
| **`boot-custom.sh`** | Unchanged | Still unchanged for this feature |

**Convention:** **`plan.md`** stays as the **historical first draft**; this section is the canonical **“how far we diverged”** narrative (per **`../../README.md`** → **VERDICT.md**).

## Decision rationale (post-discovery)

- **Shell stays authoritative** for backup / restore / reboot (**`crt-mode-switch-combo`**).
- **Python is justified** where **pure shell cannot** replace evdev cleanly and **triggerhappy’s model** fails on target hardware; scope is **one device**, **four-button chord**, **spawn bash** (see **`design/README.md`**).
- **Original backup design** (full **`crt_combo_listener.py`** on **`boot-custom.sh`**) remains **reserve** for boards that need multi-device / analog-axis logic; Deck path is **lighter**.

## Unanticipated bugs / gotchas

- **`/usr/bin/crt-mode-switch-combo`** as a **directory** on some deploys; installer must **`rm -rf`** before **`mv`** file.
- Spawn combo with **`/bin/bash /path/to/combo`**, not execute bit alone, where permissions or layout bite.
- **`flock`** + blind **sleep** ordering: lock must be taken **before** parallel sleeps truncate the lock file.
- **`batocera-save-overlay`** unavailable on some setups: **userdata**-resident scripts + logs matter.
- **`/userdata/system/crt-mode-switch-combo.debug`:** if present, combo exits after haptics and **never** runs restore or **`/sbin/poweroff`** / **`/sbin/reboot`** (easy to mistake for “reboot broken”). See **`debug/02-crt-mode-switch-combo-debug-operator.md`**.
- **Batocera python-evdev `Effect`:** rumble fields live on **`effect.u.ff_rumble_effect`**, not **`effect.u.rumble`**; missing that caused python exit 1 and no haptic until fixed.
- **Shutdown from user service:** spawn may have **`PATH`** without **`/sbin`**; combo uses **`/sbin/poweroff`**, **`/sbin/reboot`**, and **`shutdown`** fallbacks.

## Models used

(Optional: record which AI / session did implementation vs review.)

## What worked / what did not

- **Worked:** bash combo reusing mode switcher modules; Deck blind switch after fixes.
- **Did not (for Deck):** rely on **`thd`** alone for the chord under **`mods_equal`** across devices.

## Root Causes

1. **Triggerhappy** chord evaluation is **not device-scoped**; extra held keys from other **`/dev/input/event*`** nodes can block **`BTN_*`** rules on **Steam Deck**.
2. **evdev** input plumbing in **portable shell** without helpers is impractical; **Python `evdev`** is already on the image.

## Changes Applied

| Location | Change (high level) |
|----------|---------------------|
| Batocera-CRT-Script | **`crt-mode-switch-combo`**, **`crt-mode-switch-watcher.py`**, **`crt_mode_switch_watcher`**, **`multimedia_keys.conf`**, ALLINONE v43 media-keys block, logging / userdata mirror (see repo and **`design/README.md`**) |
