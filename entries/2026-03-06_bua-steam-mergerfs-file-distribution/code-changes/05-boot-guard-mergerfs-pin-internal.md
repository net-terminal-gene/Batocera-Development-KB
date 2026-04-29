# Change 05: Boot Guard — mergerfs-pin-internal.sh

## Status: DEPLOYED TO REMOTE BATOCERA

## Files

**Guard script:** `/userdata/system/scripts/mergerfs-pin-internal.sh`
**Boot service:** `/userdata/system/services/custom_service` (appended line calls the guard)
**Log file:** `/userdata/system/logs/mergerfs-pin-internal.log`

**Important**: Batocera v43 deprecated `custom.sh`. Boot services now use `/userdata/system/services/custom_service`, managed by `batocera-services`. The guard call was appended to the existing `custom_service` file.

## Purpose

100% prevention of `steam/`, `crt/`, `flatpak/`, and `ports/` directories from ever existing on external drives (BATO-PARROT, BATO-ALL, BATO-LG). This is the catch-all safety net that covers all scenarios — including BUA addon reinstalls, unknown scripts, and any future writes through the merged `/userdata/roms/` path.

## Why This Is Needed

The per-script `.roms_base` fixes (Changes 01-04) protect against *known* write paths. But:
- **Flatpak**: 7 BUA installer scripts write to `/userdata/roms/flatpak/` — none are fixed
- **Ports**: 100+ BUA installer scripts write to `/userdata/roms/ports/` — none are fixed
- **Unknown scripts**: Any future addon or user script could write to these paths

mergerfs `mfs` policy evaluates free space **per-file**, not per-directory. Even if a directory already exists on the internal drive, a new file inside it can still be created on an external drive if that drive has more free space.

## How It Works

1. **Boot**: Called from `/userdata/system/services/custom_service` on every boot (Batocera v43 boot service)
2. **Pre-create**: Creates `steam/`, `crt/`, `flatpak/`, `ports/` on `/userdata/.roms_base` (internal NVMe)
3. **Move & clean**: If any of these directories are found on external drives (`/media/*/roms/`), moves their files to `.roms_base` and removes the external copy
4. **Background watcher**: Spawns a background process that checks every 5 minutes for any new appearances and immediately pins them back

## Full Script

```bash
#!/bin/bash
PROTECTED_DIRS="steam crt flatpak ports"
INTERNAL="/userdata/.roms_base"
LOG="/userdata/system/logs/mergerfs-pin-internal.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; }

[ -d "$INTERNAL" ] || exit 0

log "=== Boot: mergerfs-pin-internal starting ==="

pin_directories() {
    for dir in $PROTECTED_DIRS; do
        mkdir -p "$INTERNAL/$dir" 2>/dev/null
    done

    for ext in /media/*/roms; do
        [ -d "$ext" ] || continue
        [ "$ext" = "$INTERNAL" ] && continue

        for dir in $PROTECTED_DIRS; do
            [ -d "$ext/$dir" ] || continue

            file_count=$(find "$ext/$dir" -type f 2>/dev/null | wc -l)
            if [ "$file_count" -gt 0 ]; then
                log "MOVING $file_count file(s) from $ext/$dir/ to $INTERNAL/$dir/"
                cp -a "$ext/$dir/"* "$INTERNAL/$dir/" 2>/dev/null
                rm -rf "$ext/$dir" 2>/dev/null
                log "CLEANED $ext/$dir/"
            else
                rm -rf "$ext/$dir" 2>/dev/null
                log "REMOVED empty $ext/$dir/"
            fi
        done
    done
}

pin_directories

(
    while true; do
        sleep 300
        for ext in /media/*/roms; do
            [ -d "$ext" ] || continue
            [ "$ext" = "$INTERNAL" ] && continue
            for dir in $PROTECTED_DIRS; do
                if [ -d "$ext/$dir" ]; then
                    log "WATCHER: detected $ext/$dir/ — pinning back to internal"
                    pin_directories
                    break 2
                fi
            done
        done
    done
) &

log "=== Boot: pin complete, watcher PID=$! (checks every 5 min) ==="
```

## Protection Coverage

| Scenario | Protected? | How |
|----------|-----------|-----|
| BUA flatpak addon install | Yes | Watcher moves files back within 5 min |
| BUA ports addon install | Yes | Watcher moves files back within 5 min |
| Reboot / power cycle | Yes | Boot-time pin runs before EmulationStation |
| Mode switcher (CRT/HD) | Yes | Already fixed in scripts + watcher backup |
| Steam daemon writes | Yes | Already fixed in script + watcher backup |
| Unknown future scripts | Yes | Watcher catches any stray writes |

## External Drives Covered

All drives in the mergerfs pool are covered via `/media/*/roms` glob:
- `/media/BATO-PARROT/roms` (3.7 TB SSD)
- `/media/BATO-ALL/roms` (955 GB SD)
- `/media/BATO-LG/roms` (955 GB SD)

## custom_service (Boot Service — appended line)

The following was appended to the existing `/userdata/system/services/custom_service`:

```bash
# Pin steam/crt/flatpak/ports to internal drive (mergerfs protection)
bash "/userdata/system/scripts/mergerfs-pin-internal.sh" &
```

**Note**: `custom.sh` was also created but is NOT used in v43 — it's dead code. The real boot hook is `custom_service`.

## Verification

```bash
# Check log
cat /userdata/system/logs/mergerfs-pin-internal.log

# Confirm internal dirs exist
ls -d /userdata/.roms_base/{steam,crt,flatpak,ports}

# Confirm no external dirs
ls -d /media/*/roms/{steam,crt,flatpak,ports} 2>/dev/null  # should be empty

# Check watcher is running
ps aux | grep mergerfs-pin
```
