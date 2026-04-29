# Design: Preserve Steam Settings Across Mode Switches

**Note:** We implemented the BUA boot-time ensure approach instead (see `2026-02-25_bua-steam-boot-ensure`). This Mode Switcher design is preserved for possible revisit.

## Goal

Ensure BUA Steam works in both HD and CRT mode by preserving `steam.emulator`, `steam.core`, and per-game `steam["*.sh"].videomode` entries when the Mode Switcher restores batocera.conf.

## BUA-Only Gate

Only run when BUA (Batocera Unofficial Addons) Steam is installed at `/userdata/system/add-ons/steam`. Flatpak Steam uses a different path and is not affected. This avoids touching batocera.conf steam.* for users who use Flatpak Steam.

## Approach: Mirror VNC Preservation

The existing VNC preservation logic in `03_backup_restore.sh` provides the pattern:

1. Before restore, extract preserve-worthy lines from source backup (or current batocera.conf)
2. Restore batocera.conf from target mode backup
3. Re-apply preserved lines (sed update or append)

## Steam Keys to Preserve

Extract and re-apply all lines matching:

```
^steam\.emulator=
^steam\.core=
^steam\[
```

This covers:
- `steam.emulator=sh`
- `steam.core=sh`
- `steam["2772080_Crystal_Breaker.sh"].videomode=854x480.60.00045` (and all per-game entries)

## Implementation Location

**File:** `Batocera-CRT-Script/.../mode_switcher_modules/steam_preservation.sh` (dedicated module)

**Sourced by:** `03_backup_restore.sh` at load time. Called from `restore_mode_files()` for both HD and CRT restores.

**Logic:**

```
# Preserve Steam settings (BUA Steam) — same pattern as VNC
local steam_temp_file="/tmp/steam_settings_$$.txt"
# Extract from source mode's backup first
if [ -f "${source_backup_dir}/userdata_configs/batocera.conf" ]; then
    grep -E '^steam\.(emulator|core)=|^steam\[' "${source_backup_dir}/userdata_configs/batocera.conf" > "$steam_temp_file" 2>/dev/null || true
fi
# Fallback to current batocera.conf
if [ ! -s "$steam_temp_file" ] && [ -f "/userdata/system/batocera.conf" ]; then
    grep -E '^steam\.(emulator|core)=|^steam\[' /userdata/system/batocera.conf > "$steam_temp_file" 2>/dev/null || true
fi

# ... batocera.conf restore happens here (cp from backup) ...

# Re-apply Steam settings
if [ -f "$steam_temp_file" ] && [ -s "$steam_temp_file" ] && [ -f "/userdata/system/batocera.conf" ]; then
    while IFS= read -r steam_line || [ -n "$steam_line" ]; do
        if [ -n "$steam_line" ]; then
            steam_key=$(echo "$steam_line" | cut -d'=' -f1)
            steam_key_escaped=$(printf '%s\n' "$steam_key" | sed 's/[[\.*^$()+?{|]/\\&/g')
            if grep -q "^${steam_key}=" /userdata/system/batocera.conf 2>/dev/null; then
                sed -i "s|^${steam_key_escaped}=.*|${steam_line}|" /userdata/system/batocera.conf 2>/dev/null || true
            else
                echo "$steam_line" >> /userdata/system/batocera.conf 2>/dev/null || true
            fi
        fi
    done < "$steam_temp_file"
    rm -f "$steam_temp_file" 2>/dev/null || true
    echo "[...]: Preserved Steam settings in batocera.conf" >> "$LOG_FILE"
fi
```

**Caveat:** Per-game `steam["rom.sh"]` keys contain `=` in the value. The `cut -d'=' -f1` yields `steam["x.sh"].videomode` — correct. Double-check sed escaping for square brackets.

## Validation

1. Install BUA Steam in HD mode → verify steam.emulator=sh, steam.core=sh in batocera.conf
2. Set per-game videomode for a Steam game
3. Run Mode Switcher: HD → CRT → verify Steam launches, videomode applied
4. Run Mode Switcher: CRT → HD → verify steam.* still present in batocera.conf, Steam launches
5. Repeat roundtrip; Steam config must persist

## Dependencies

- **BUA Steam fix** (batocera-unofficial-addons): es_systems_steam.cfg -system steam, sh emulator. Install script must add steam.emulator=sh, steam.core=sh.
- **Mode Switcher change**: Add Steam preservation block. No dependency on BUA version — if steam.* exists, preserve it; if not, no-op.
