# Design — Mode Switcher Empty Backups

## Architecture

### Current Flow

```
mode_switcher.sh main()
  └─ run_mode_switch_ui(target_mode)
       ├─ check_mandatory_configs()
       │    ├─ get_current_hd_output()        → reads mode_backups/hd_mode/video_settings/video_output.txt → EMPTY
       │    ├─ get_current_crt_backup_output() → reads mode_backups/crt_mode/video_settings/video_output.txt → EMPTY
       │    │   └─ fallback: get_current_crt_output() → reads batocera.conf global.videooutput → MISSING
       │    └─ get_crt_boot_resolution()       → reads batocera.conf global.videomode → MISSING
       │         └─ fallback: reads mode_backups/crt_mode/video_settings/video_mode.txt → EMPTY
       │
       │  Result: NEEDS_HD_CONFIG=true, NEEDS_CRT_CONFIG=true, NEEDS_BOOT_CONFIG=true
       │
       ├─ [Forces user through HD output selection dialog]
       ├─ [Forces user through CRT output selection dialog]
       ├─ [Forces user through boot resolution dialog]
       ├─ [Shows summary → user confirms]
       └─ [Writes backup files] ← Only happens HERE, at the very end
```

### Key Behavior

Backup files are the **only** persistent storage for mode switcher settings, but they're only written after a complete wizard flow. On first run (or after any incomplete run), the wizard has no memory. This is by-design — after one complete cycle, subsequent runs detect existing backups and skip to the summary.

### Data Sources Available (Not Used)

| Setting | Live Source | Currently Checked |
|---------|-----------|-------------------|
| CRT output | `batocera.conf` `global.videooutput` | Only as last fallback, and the key is missing |
| HD output | None (no HD-specific key in batocera.conf) | Backup file only |
| Boot resolution | `batocera.conf` `global.videomode` | Checked but key is missing |
| Boot resolution | `videomodes.conf` Boot_ entries | Used for name lookup only, not as a default |
| Current mode | `batocera-resolution currentMode` | Returns empty on this system |
