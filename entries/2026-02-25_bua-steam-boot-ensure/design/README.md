# Design — BUA Steam Boot-Time Ensure

## Architecture

```
Boot
  └── custom.sh
        └── ensure_steam_batocera_conf.sh
              ├── Check: BUA Steam installed? (/userdata/system/add-ons/steam)
              ├── Check: batocera.conf exists?
              ├── Check: steam.emulator already present? → exit 0
              └── Else: append steam.emulator=sh, steam.core=sh
```

## Key Logic

- **Gate**: Only run when BUA Steam dir exists; skip if Flatpak Steam (different path).
- **Idempotent**: If `steam.emulator=` already in batocera.conf, exit without change.
- **Append-only**: When missing, add both keys.
- **Registration**: steam.sh and steam2.sh download the script and add `bash /userdata/system/add-ons/steam/extra/ensure_steam_batocera_conf.sh &` to custom.sh on install.

## Zero Impact When Config Is Intact

If steam.* is already present (typical after fresh install), the script exits on every boot. No changes to batocera.conf. No impact on users who don't need the fix.
