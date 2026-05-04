# Debug — v43 game saves layout

**Steam ↔ ES regression (commands + checklist):** see **`../research/steam-es-batocera-steam-update-regression.md`** (end of file: re-confirmation on **v43**).

## Verification (repeat on v42)

Use **x86_64** for a fair compare to this session; if v42 is **Zen3**, say so in upstream notes.

```bash
batocera-version
cat /userdata/system/data.version
df -h /userdata
mount | grep -E 'userdata|overlay'
ls -la /userdata/saves
du -sh /userdata/saves/* 2>/dev/null
test -f /userdata/system/.roms_base && cat /userdata/system/.roms_base || echo 'no .roms_base'
find /userdata/saves -maxdepth 3 -type d
ls -la /userdata/saves/flatpak/data/.var/app/com.valvesoftware.Steam/.local/share/Steam 2>/dev/null | head
```

## Failure signs

| Symptom | Likely cause |
|---------|----------------|
| Saves “missing” after upgrade | Path change between versions; compare `saves/` tree and flatpak `.var` |
| Steam reinstalls everything | Different flatpak data dir or wiped `saves/flatpak` |
| Steam games never appear in ES after install | **`batocera-steam-update`** scan dir empty vs where Steam writes **`*.desktop`** — see **`research/steam-es-batocera-steam-update-regression.md`** |
