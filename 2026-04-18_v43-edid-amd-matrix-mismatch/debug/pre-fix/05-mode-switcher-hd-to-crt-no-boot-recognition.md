# 05 — Mode switcher HD→CRT: prompts repeat (“should already be saved”)

**Date:** 2026-04-19  
**Scope:** **X11-only** (same session rules as [README](README.md)).  
**Observation:** When switching **HD → CRT** in the HD/CRT Mode Switcher, the UI asks again for choices that feel already set (outputs and/or **CRT boot resolution**). **Why?**

## Short answer

The switcher does **not** treat “whatever is in `batocera.conf` right now” as the single source of truth. It uses:

1. **Dedicated backup files** under **`/userdata/Batocera-CRT-Script-Backup/mode_backups/`** (e.g. `hd_mode/video_settings/video_output.txt`, `crt_mode/video_settings/video_output.txt`, `crt_mode/video_settings/video_mode.txt`).
2. **`get_crt_boot_resolution()`**, which looks for a **`Boot_*`** name or a resolvable mode ID. In **HD mode**, live `batocera.conf` often has **`global.videomode=default`**, which is **not** a CRT boot line, so the script can conclude **boot is not configured** and prompt again.

So “I already set that” in **EmulationStation** (or a prior partial flow) is **not always** the same as “the mode switcher has a complete saved triple (HD output, CRT output, CRT boot).”

## Code references (Batocera-CRT-Script)

### HD output “memory” is the HD backup file, not only live conf

```76:80:userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh
get_current_hd_output() {
    local hd_video_file="${MODE_BACKUP_DIR}/hd_mode/video_settings/video_output.txt"
    if [ -f "$hd_video_file" ]; then
        grep '^global\.videooutput=' "$hd_video_file" 2>/dev/null | cut -d'=' -f2 | head -1
    fi
}
```

If you reached **HDMI desktop** by setting **`global.videooutput`** in ES and rebooting ([03](03-mode-switcher-crt-to-hd-pre-reboot.md), [04](04-hd-mode-pre-mode-switcher.md)) **without** completing a mode switcher run that **writes** `hd_mode/video_settings/video_output.txt`, **`get_current_hd_output` can be empty** → the wizard may ask for **HD output** again when it needs that value for the round-trip.

### CRT boot resolution: `default` in HD mode is not a Boot_ line

`get_crt_boot_resolution()` reads `batocera.conf` first, then CRT backup. It only returns early when `global.videomode` is a **`Boot_*`** string or maps from a mode ID (see same file ~448–490). With **`global.videomode=default`** (typical on HDMI in [04](04-hd-mode-pre-mode-switcher.md)), there is **no** CRT boot string → **`check_mandatory_configs`** sets **`NEEDS_BOOT_CONFIG=true`** → **boot resolution dialog** again.

### What “saved” means on confirm

When the UI finishes successfully, it writes the backup files explicitly:

```779:785:userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh
    mkdir -p "${MODE_BACKUP_DIR}/hd_mode/video_settings"
    echo "global.videooutput=$working_hd" > "${MODE_BACKUP_DIR}/hd_mode/video_settings/video_output.txt"
    ...
    mkdir -p "${MODE_BACKUP_DIR}/crt_mode/video_settings"
    echo "global.videooutput=$working_crt" > "${MODE_BACKUP_DIR}/crt_mode/video_settings/video_output.txt"
```

Until that runs, “saved” in the **switcher’s** sense may be incomplete.

### HD→CRT path when not in CRT mode (writes boot from selection)

```821:827:userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh
    elif [ -n "$boot_mode_id" ]; then
        # Not in CRT mode (HD→CRT switch): always write the user's selection.
        ...
        echo "global.videomode=$boot_mode_id" > "${MODE_BACKUP_DIR}/crt_mode/video_settings/video_mode.txt"
```

So the design **expects** you to **confirm** boot resolution on HD→CRT when the current `batocera.conf` cannot supply a `Boot_*` / mode ID (e.g. **`default`**).

## How this ties to this session’s captures

| Phase | `global.videomode` (typical) | Mode switcher boot detection |
|-------|------------------------------|------------------------------|
| [02](02-crt-mode-pre-mode-switcher.md) CRT | `Boot_576i …` or mode ID | Can resolve |
| [04](04-hd-mode-pre-mode-switcher.md) HD | **`default`** | **No `Boot_*`** in live conf |

So “no boot recognition” after HD is **consistent with code**, not necessarily a bug.

## Practical notes

1. **One full HD↔CRT cycle** through the mode switcher (confirm all three: HD output, CRT output, CRT boot) populates **`mode_backups/`** so later runs can skip prompts when files are present and consistent.
2. If prompts should stop after that, verify files exist and are non-empty:

```bash
ls -la /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/
ls -la /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/
grep BUILD_15KHz_Batocera.log -E 'Config check|Needs -|Mode switch UI'
```

3. **`BUILD_15KHz_Batocera.log`** lines from `run_mode_switch_ui` (`Config check`, `Needs - HD/CRT/Boot`) record what the script thought was missing.

## Reference

- [03-mode-switcher-crt-to-hd-pre-reboot.md](03-mode-switcher-crt-to-hd-pre-reboot.md)
- [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md)
