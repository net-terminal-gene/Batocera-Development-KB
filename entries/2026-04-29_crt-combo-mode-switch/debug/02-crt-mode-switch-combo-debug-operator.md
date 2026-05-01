# Operator: `crt-mode-switch-combo.debug` (QA / tuning)

**Purpose for wiki:** document the optional dry-run flag so contributors do not confuse “rumble worked, no shutdown” with a broken install.

## What it is

- **Path:** `/userdata/system/crt-mode-switch-combo.debug`
- **Semantics:** if this path **exists as a file** (empty is enough), `crt-mode-switch-combo` runs **only** through: flock → 5s blind sleep → **haptic** (python/evdev `FF_RUMBLE`, then hidraw fallback for Deck HID) → logs → **`exit 0`**.
- It **skips:** `check_crt_script_installed`, CRT/HD guards, `backup_mode_files` / `restore_mode_files`, `es_systems_crt.cfg` finalization, **`/sbin/poweroff`** / **`/sbin/reboot`**.

## Enable (tuning rumble or chord without changing mode)

```bash
touch /userdata/system/crt-mode-switch-combo.debug
```

Then trigger the blind chord (or run the combo script). Tail logs:

- `/userdata/system/logs/crt-script-mode-switch.log`
- `/userdata/system/logs/crt-mode-switch-watcher.log` (combo lines are mirrored here too)

## Disable (production / full CRT→HD test)

```bash
rm -f /userdata/system/crt-mode-switch-combo.debug
```

Without this file, the combo runs the **full** path after haptics (guards, backup, restore, shutdown).

## Installer note

**`Batocera-CRT-Script-v43.sh` does not create this file.** A fresh machine behaves as production until someone creates `.debug`.

## Related: watcher debug

- **`/userdata/system/crt-mode-switch-watcher.debug`** (empty file) enables per-key logging in `crt-mode-switch-watcher.py` via `CRT_MODE_SWITCH_WATCHER_DEBUG=1` after **restarting** `crt_mode_switch_watcher`. Unrelated to combo dry-run except for log volume.

## Wiki lift (copy into Redemp CRT wiki when ready)

Short user-facing blurb:

> **Optional test file:** If you create `/userdata/system/crt-mode-switch-combo.debug`, the blind chord will only vibrate the pad and will **not** switch to HD or power off. Remove the file for the real switch. The CRT Script installer does not add this file.
