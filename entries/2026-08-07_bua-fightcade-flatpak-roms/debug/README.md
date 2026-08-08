# Debug — BUA Fightcade Flatpak — Missing ROMs Directory

## Verification

```bash
# Flatpak app present?
flatpak list | grep -i fightcade

# Data tree (before/after first run)
FC_DATA=/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade
ls -la "$FC_DATA" 2>/dev/null || echo "no .var tree yet"
ls -la "$FC_DATA/data" 2>/dev/null || echo "no data/ yet"
ls -la "$FC_DATA/data/ROMs" 2>/dev/null || echo "no ROMs/ yet"

# Find any ROMs dirs under Fightcade Flatpak
find /userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade -type d -name 'ROMs' 2>/dev/null
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| No `data/ROMs` after install | Flatpak never seeded; needs first-run or installer mkdir |
| Path exists but invisible in F1 browser | Dot-path under `.var`; Show Hidden required |
| ROMs dir empty / wrong platform subdirs | App creates subdirs only after TEST / emulator touch |
