# Design — HD/CRT Mode Switcher

## Architecture

### Modular Structure

```
mode_switcher.sh (orchestrator)
├── 01_mode_detection.sh    — detect current mode (HD vs CRT)
├── 02_hd_output_selection.sh — DRM sysfs output detection, dialog UI
├── 03_backup_restore.sh    — overlay swap, batocera.conf, MAME, RetroArch, scripts, video settings
└── 04_user_interface.sh    — dialog wrappers, safety warnings
```

### Key Design Decisions

1. **Overlay file swapping** (not editing inside overlay) — HD mode removes overlay entirely for vanilla Batocera; CRT mode restores full overlay
2. **DRM sysfs** for output detection — more reliable than xrandr when in CRT mode
3. **Complete folder swapping** for MAME and RetroArch — prevents config mixing
4. **Per-file approach for scripts/** — preserves user custom scripts while managing CRT Script files
5. **Hybrid display management** — X11 xorg.conf.d + batocera-save-overlay + batocera-resolution setOutput
6. **Forced selection** — if VIDEO OUTPUT or VIDEO MODE not configured, user must select before switching
