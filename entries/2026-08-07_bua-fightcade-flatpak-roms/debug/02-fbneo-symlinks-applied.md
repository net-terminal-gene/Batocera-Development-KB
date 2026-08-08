# Debug — FBNeo Fightcade symlinks applied

**Host:** batocera.local  
**When:** 2026-08-07

## Why not one symlink for whole `fbneo/`

Batocera arcade lives flat in `/userdata/roms/fbneo` with **no** console subdirs. Consoles are separate Batocera systems. A single `ROMs/fbneo` → `roms/fbneo` link would hide console folders.

So `ROMs/fbneo` stays a real directory:
- **Arcade root:** one symlink per `.zip` → `/userdata/roms/fbneo/<name>.zip` (**2126**)
- **Console dirs:** folder symlinks where Batocera has Fightcade-style sets

## Links

| Fightcade path | Target |
|----------------|--------|
| `ROMs/fbneo/*.zip` (2126) | `/userdata/roms/fbneo/*.zip` |
| `ROMs/fbneo/megadrive` | `/userdata/roms/megadrive` |
| `ROMs/fbneo/nes` | `/userdata/roms/nes` |
| `ROMs/fbneo/gamegear` | `/userdata/roms/gamegear` |
| `ROMs/fbneo/coleco` | `/userdata/roms/colecovision` |
| `ROMs/fbneo/pce` | `/userdata/roms/pcengine` |
| `ROMs/fbneo/sg1000` | `/userdata/roms/sg1000` |
| `ROMs/fbneo/msx` | `/userdata/roms/msx1` |

Empty real dirs (no Batocera Fightcade set yet): `nes_fds`, `sms`, `spectrum`, `sgx`, `tg16`.

## Flatpak override

Granted host filesystem access for the linked Batocera paths (plus prior flycast/snes/bios paths).

## Host checks

- `mslug3.zip` resolves through arcade symlink
- `megadrive/sonic2.zip` resolves through megadrive symlink

## QA (user)

| Test | Result |
|------|--------|
| Launch FBNeo arcade / console titles via Flatpak Fightcade | **PASS** — user reported everything working (2026-08-07) |
