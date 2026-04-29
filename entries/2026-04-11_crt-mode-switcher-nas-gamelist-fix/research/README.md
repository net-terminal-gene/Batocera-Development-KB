# Research — CRT Mode Switcher: NAS Gamelist Visibility Fix

## Findings

### NAS Write-Back Race Condition

`/userdata/roms/crt` is synced to a NAS server via CIFS. When `install_crt_tools()` runs:

1. `rm -rf $CRT_ROMS/crt/*` — deletion is queued to the NAS
2. `cp mode_switcher.sh ...` — write is queued to the NAS
3. Reboot is issued immediately after

On reboot, the NAS client flushes pending writes in order, but if the reboot interrupts the flush mid-way, only the `rm -rf` (deletion) may have persisted. The subsequent `cp` writes can be lost.

This is not unique to CIFS — any buffered filesystem (NFS with async, overlayfs, or even local ext4 under high I/O) can exhibit this.

### gamelist.xml `<hidden>` Tag Behavior

EmulationStation reads `<hidden>true</hidden>` within a `<game>` block and excludes that entry from the system's game list. The system itself still appears in the ES main menu as long as at least one entry is visible.

Confirmed via live test: 0 `<hidden>` tags in CRT mode = all tools visible. Multiple `<hidden>true</hidden>` tags in HD mode = only mode_switcher visible.

### Origin

First reported in `2026-04-06_crt-mode-switcher-empty-backups`. That session concluded the empty-backups behavior was expected first-run behavior and closed with "no code changes needed." The `rm -rf` + NAS timing root cause was not investigated at that time.

### emulatorlauncher.py Resolution Crash (separate issue, same session)

During diagnosis, `mode_switcher.sh` failed to launch from ES with:

```
ValueError: invalid literal for int() with base 10: ''
```

Root cause: `emulatorlauncher.py` calls `videoMode.getCurrentResolution()` before launching any `.sh` script. This calls `batocera-resolution currentResolution`, which calls `xrandr --currentResolution $(xrandr --listPrimary)`. When no primary output is set (e.g. when the Batocera display is not the OS-foreground display, causing `xrandr` to see the output as "disconnected"), `listPrimary` returns empty and `currentResolution` returns empty.

Fix: ensure Batocera's display is the primary/foreground screen before launching ES. Not a code fix — a hardware/environment issue specific to the test setup.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

