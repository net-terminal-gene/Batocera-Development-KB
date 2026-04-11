# 00 — Pre-Add-Non-Steam

Baseline state on remote Batocera before running Add Non-Steam Games. Captured via `~/bin/ssh-batocera.sh`.

## non-steam-games/

```
/userdata/system/add-ons/steam/non-steam-games/
├── Infinos 2.wsquashfs    (18 MB, copy from roms/windows)
├── Infinos2/              (extracted, ready for Add Non-Steam)
└── TestTwoExes/           (2 exes for exe picker test)
```

### Infinos2/ (2 exes — exe picker test)

| File           | Size   |
|----------------|--------|
| KeyConfig.exe  | 68 KB  |
| infinos_2.EXE  | 958 KB |
| CONFIG.DAT     | 165 B  |
| CONFIG.INI     | 686 B  |
| GAME.BMP       | 78 KB  |
| GAME.DAT       | 51 MB  |
| GamePad.dll    | 98 KB  |
| autorun.cmd    | 19 B   |
| instruction_card.png | 826 KB |
| score.bin      | 9 KB   |
| wuvorbis.dll   | 197 KB |

### TestTwoExes/ (2 exes — exe picker test)

| File       | Size   |
|------------|--------|
| Game.exe   | 958 KB |
| Launcher.exe | 958 KB |

## Add Non-Steam Games app

**Launcher:** `/userdata/roms/steam/Add_Non-Steam_Games.sh`

```bash
#!/bin/bash
# xterm wrapper ensures keyboard and controller work with dialog (same as mode_switcher)
DISPLAY=:0.0 xterm -fs 15 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0 /userdata/system/add-ons/steam/extra/add-non-steam-game.sh"
```

**Main script:** `/userdata/system/add-ons/steam/extra/add-non-steam-game.sh`

## Steam roms/steam/

- **53** `.sh` launchers (all Steam app IDs, e.g. 1030300_Hollow_Knight_Silksong.sh)
- No non-Steam launchers yet (no CRC32-style shortcut IDs like 0x8xxxxxxx)

## compatdata/

Prefixes present: 1031480, 1034900, 1049320, 1091500, 1257360, 1263240, 1313140, 1364780, 1384160, 1493710, 1562700, 1678420, 1883260, 2025840, 2230650, 2273430, 2379780, 2407270, 246580, 2492040, …

All numeric (Steam app IDs). No non-Steam compatdata prefixes yet.

## mergerfs

- `/userdata/.roms_base` exists → mergerfs in use
- Script uses `ROMS_ROOT=/userdata/.roms_base` when present

## Next step

Run Add Non-Steam Games from ES > Steam. Expect:
- Exe picker for Infinos2 (KeyConfig.exe vs infinos_2.EXE)
- Exe picker for TestTwoExes (Game.exe vs Launcher.exe)
- New launchers in `/userdata/roms/steam/` with CRC32 shortcut IDs
- New compatdata prefixes on first game launch
