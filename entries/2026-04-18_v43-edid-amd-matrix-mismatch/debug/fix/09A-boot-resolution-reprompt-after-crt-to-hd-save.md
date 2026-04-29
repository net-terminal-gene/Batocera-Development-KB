# 09A - Boot resolution prompts again (expected with current save logic)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Parent step:** [09-hd-mode-pre-mode-switcher.md](09-hd-mode-pre-mode-switcher.md)  
**Scope:** X11-only ([../README.md](../README.md)).

## Observation

After the second **HD** baseline (**09**), opening the mode switcher toward **CRT** can **ask for CRT boot resolution again**, even though you already chose **Boot_576i** earlier in the ladder.

**Should it already be saved?** Partially. The **user choice** is reflected in logs and was written to **`mode_backups/`**, but a **later save overwrites** the backup **`video_mode.txt`** with a **live X mode string** that **does not** round-trip back to the **`Boot_…`** display name the UI uses for **`Config check`**.

## Evidence (device)

### `mode_backups/crt_mode/video_settings/` (capture)

```
video_mode.txt   -> global.videomode=769x576.49.97
es_resolution.txt -> es.resolution=769x576.49.97
video_output.txt -> global.videooutput=DP-1
```

### `batocera.conf` (HD session)

```
es.resolution=default
global.videomode=default
```

While in **HD**, **`get_crt_boot_resolution`** does not get a **CRT** mode from **`batocera.conf`**, so it falls back to **`video_mode.txt`** in **`crt_mode`** backup.

### `BUILD_15KHz_Batocera.log` (selected lines)

**When boot was recognized** (start of second **CRT→HD**, fix **08**):

```
[11:03:07]: Config check - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[11:03:07]: Needs - HD: false, CRT: false, Boot: false, All configured: true
```

**After that run finished**, the same log shows **`Saved synced CRT mode`** (overwriting backup **`videomode`** with **`currentMode`**):

```
[11:03:18]: Converting boot mode - input: 'Boot_576i 1.0:0:0 15KHz 50Hz', output: '769x576.50.00053'
[11:03:18]: Saved synced CRT mode: 769x576.49.97 (from currentMode, display: Boot_576i 1.0:0:0 15KHz 50Hz)
```

**Later**, opening the switcher again from **HD**:

```
[19:06:47]: Config check - HD: HDMI-2, CRT: DP-1, Boot: 
[19:06:47]: Needs - HD: false, CRT: false, Boot: true, All configured: false
[19:06:47]: Boot resolution selection started
```

So **`Boot:`** in **`Config check`** is **empty** even though **`video_mode.txt`** is **non-empty**: the UI treats boot as **missing** because it cannot derive the **`Boot_…`** label.

## Root cause (code path)

1. **`check_mandatory_configs`** sets **`NEEDS_BOOT_CONFIG=true`** when **`get_crt_boot_resolution`** returns empty (`02_hd_output_selection.sh`, **`check_mandatory_configs`** / **`get_crt_boot_resolution`**).

2. **`get_crt_boot_resolution`** reads **`global.videomode`** from **`crt_mode/video_settings/video_mode.txt`**. If the value is a **mode ID** (not a string starting with **`Boot_`**), it calls **`get_boot_display_name`** to map that ID to the **`Boot_…`** menu label using **`videomodes.conf`** boot entries and a **prefix** fallback between IDs.

3. On **CRT→HD** completion while still in **CRT**, the **save** block at the end of **`run_mode_switch_ui`** prefers **`batocera-resolution currentMode`** for the CRT backup **`video_mode.txt`**, intentionally (sync with live X, avoid **`emulatorlauncher`** mismatch). That writes **`769x576.49.97`** here:

```805:811:Batocera-CRT-Script/userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh
    if [ "$current_detected" = "crt" ] && command -v batocera-resolution >/dev/null 2>&1; then
        local synced_mode
        synced_mode=$(batocera-resolution currentMode 2>/dev/null)
        if [ -n "$synced_mode" ]; then
            echo "global.videomode=${synced_mode}" > "${MODE_BACKUP_DIR}/crt_mode/video_settings/video_mode.txt"
            echo "es.resolution=${synced_mode}" > "${MODE_BACKUP_DIR}/crt_mode/video_settings/es_resolution.txt"
            echo "[$(date +"%H:%M:%S")]: Saved synced CRT mode: $synced_mode (from currentMode, display: $working_boot)" >> "$LOG_FILE"
```

4. **`get_boot_display_name`** for **`769x576.49.97`** does **not** match the **`videomodes.conf`** ID **`769x576.50.00053`** from the log line **`Converting boot mode … output: '769x576.50.00053'`** (prefix logic compares **`49.97`** vs **`50.00053`**, so no hit). Result: **empty** boot for **`Config check`**, so the **boot picker** runs again.

## Answer in one line

Yes: the choice was saved, then overwritten by the synced `currentMode` string (on purpose for CRT or X sync). That string is not one the boot picker can reverse-map to a `Boot_…` label with the current ID tables, so the UI asks again.

## Relation to other KB work

- **`Batocera-Development-KB/2026-04-14_crt-mode-switcher-boot-resolution-not-persisted/`** addressed **truncation** and **`es.resolution`** restore; **09A** is a **separate** issue: **interlaced vs canonical boot ID** in **`video_mode.txt`** after **CRT→HD** save.
- Not the same as **pre-fix 05** (empty **Boot** before first save); this is **after** a full ladder when **`video_mode.txt`** holds **`769x576.49.97`**.

## Recommendation (best fix)

**Add a small sidecar file** under **`crt_mode/video_settings/`** that stores the **user’s boot choice as the full `Boot_…` display string** (the same value as **`working_boot`** when they confirm boot). Example name: **`crt_boot_display.txt`** (one line, or `KEY=value` matching other backup files).

**Behavior:**

1. **Write** the sidecar **whenever** the user confirms a boot resolution (same places **`video_mode.txt`** gets a boot-related write today: the **`run_mode_switch_ui`** save block after **`Saving selections`**, and any HD→CRT path that already persists **`boot_mode_id`**).
2. **`get_crt_boot_resolution`**: if the sidecar exists and has a non-empty line that starts with **`Boot_`**, return it **first**, before **`batocera.conf`** or **`video_mode.txt`** heuristics. If the sidecar is missing (old backups), keep today’s fallback chain.
3. **Do not** overwrite or clear that sidecar when the **CRT→HD** path runs **`Saved synced CRT mode`** into **`video_mode.txt`**. Synced **`currentMode`** stays **only** in **`video_mode.txt`** / **`es_resolution.txt`** for the **emulatorlauncher** alignment the comments describe.

**Why this over other options:**

- **Same design language** as **`es_resolution.txt`**: one artifact for “what X needs,” another for “what the wizard promised.”
- **No fuzzy ID matching** (no guessing that **`49.97`** “equals” **`50.00053`** across profiles and monitors).
- **Does not roll back** the **`currentMode`** sync; that fix stays intact.
- **Testable**: after **CRT→HD**, **`video_mode.txt`** can show **`769x576.49.97`** while **`Config check`** still shows **`Boot: Boot_576i …`** because the sidecar still holds the label.

**Acceptable variant:** store **canonical `boot_mode_id`** from **`get_boot_mode_id`** in the sidecar instead of **`Boot_…`**, as long as **`get_crt_boot_resolution`** reads it and maps through **`get_boot_display_name`** successfully. Slightly more fragile if **`videomodes.conf`** changes, so **prefer storing the literal `Boot_…` string** the user picked.

**Status:** Implemented in **`Batocera-CRT-Script`** **`Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh`** (**`crt_boot_display.txt`** sidecar + **`get_crt_boot_resolution`** read). **Device QA:** **[12-mode-switcher-crt-to-hd-pre-reboot.md](12-mode-switcher-crt-to-hd-pre-reboot.md)** (**CRT→HD**, **`Boot:`** filled with synced **`video_mode.txt`**); **[14-mode-switcher-hd-to-crt-pre-reboot.md](14-mode-switcher-hd-to-crt-pre-reboot.md)** (**HD→CRT**, **no** boot picker, **`Boot:`** filled from sidecar).

## Alternatives considered (not preferred)

| Approach | Drawback |
|----------|----------|
| Heuristic **`get_boot_display_name`** (treat **49.97** / **50.00** / **50.00053** as one family) | Easy to attach the wrong **`Boot_`** when multiple boot lines share a similar raster. |
| Stop overwriting **`video_mode.txt`** with **`currentMode`** on **CRT→HD** | Re-opens the **`emulatorlauncher`** / **`changeMode()`** mismatch the sync block was written to avoid. |
| Rely on **`batocera.conf`** while in **HD** | In **HD**, **`global.videomode`** is **`default`**, so it does not carry **CRT** boot intent. |

## Did the recent `03_backup_restore.sh` work cause this?

**No.** The **EFI / syslinux** work in **`03_backup_restore.sh`** does **not** write **`mode_backups/crt_mode/video_settings/video_mode.txt`** or implement **`get_crt_boot_resolution`**. The line that overwrites the backup with **`batocera-resolution currentMode`** (log tag **`Saved synced CRT mode`**) lives only in **`02_hd_output_selection.sh`**, in the **save** block at the end of **`run_mode_switch_ui`**.

**`03_backup_restore.sh`** does **read** **`video_mode.txt`** when restoring **CRT** / **HD** mode files, but it does **not** create the **49.97** vs **`videomodes.conf`** ID mismatch. That mismatch appears when **02** replaces a mappable **`global.videomode=`** line in the backup with **`currentMode`** after a **CRT→HD** wizard completion.

## Why it can feel new

1. **Order of operations:** On the **first** **CRT→HD** after an **HD→CRT** save, **`video_mode.txt`** may still hold the **canonical boot mode ID** from the **HD→CRT** branch (**`Saved boot mode ID:`** in the log). **`get_boot_display_name`** can still map that, so **`Config check`** shows **`Boot: Boot_576i …`** filled.
2. **After** that **CRT→HD** run finishes, **02** runs **`Saved synced CRT mode`** and **`video_mode.txt`** becomes **`769x576.49.97`** (or similar). The **next** time you open the switcher from **HD**, **`get_crt_boot_resolution`** can no longer derive **`Boot_…`**, so the boot picker returns. That is easy to read as “something new broke,” but it is the **second exposure** of the same **02** design, not a separate regression from **03**.

On this repo’s **`crt-hd-mode-switcher-v43`** tip, **`02_hd_output_selection.sh`** (including the **`currentMode`** sync block) landed with the same squashed mode-switcher commit as **`03_backup_restore.sh`** (`ed49924` in this clone), not as a later follow-up patch.

## Reference

- [09-hd-mode-pre-mode-switcher.md](09-hd-mode-pre-mode-switcher.md)  
- [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md)  
- Repo: **`Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh`** (`get_crt_boot_resolution`, `get_boot_display_name`, **`run_mode_switch_ui`** save block after **`Saving selections`**)
