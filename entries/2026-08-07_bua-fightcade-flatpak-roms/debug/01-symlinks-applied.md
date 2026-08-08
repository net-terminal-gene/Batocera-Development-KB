# Debug — Symlinks applied (except fbneo)

**Host:** batocera.local  
**When:** 2026-08-07

## Links created

Under `/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/ROMs/`:

| Link | Target |
|------|--------|
| `flycast/atomiswave` | `/userdata/roms/atomiswave` |
| `flycast/dreamcast` | `/userdata/roms/dreamcast` |
| `flycast/naomi` | `/userdata/roms/naomi` |
| `flycast/naomi2` | `/userdata/roms/naomi2` |
| `flycast/data` | `/userdata/bios/dc` |
| `snes9x` | `/userdata/roms/snes` |

Left as real empty dirs (not linked):

- `ROMs/fbneo`
- `ROMs/ggpofba`

## Flatpak override (system)

```
filesystems=/userdata/roms/atomiswave;/userdata/roms/naomi;/userdata/roms/naomi2;/userdata/roms/dreamcast;/userdata/roms/snes;/userdata/bios/dc;
```

## Notes

- `flycast/data` → `bios/dc` matches SETUP layout. Flatpak emulator `data` still points at `config/flycast/data` (nvmem); BIOS visibility for Flycast may need a follow-up if games complain.
- Host-side listing through `snes9x` link resolves (zips visible).
- **Not done:** fbneo symlink.

## Validation

| Test | Result | When |
|------|--------|------|
| Launch Naomi game via Flatpak Fightcade | **PASS** — no issues | 2026-08-07 (user) |
| Launch Atomiswave *Fist of the North Star* (`fotns`) after removing `flycast/data` | **PASS** (user reported launch) | 2026-08-07 |

[Inference] Per-folder symlinks + Flatpak `--filesystem` overrides are sufficient for Naomi and Atomiswave. `ROMs/flycast/data` → `bios/dc` is **not required** for these launches.

## Follow-up: removed `flycast/data` link

**2026-08-07:** Removed `ROMs/flycast/data` → `/userdata/bios/dc` for A/B test (user). Remaining flycast links: atomiswave, dreamcast, naomi, naomi2 only.

BIOS still reachable via game folders (not a clean “no BIOS anywhere” test):
- `/userdata/roms/naomi/naomi.zip` (via `naomi` link)
- `/userdata/roms/atomiswave/awbios.zip` (via `atomiswave` link)

| Dreamcast launch without `flycast/data` (e.g. Soulcalibur) | **FAIL** — exits | 2026-08-07 (user) |
| Restored `ROMs/flycast/data` → `/userdata/bios/dc` | done; Dreamcast still exited | 2026-08-07 |
| Copied BIOS into `config/flycast/data/` (real Flycast data path) | BIOS OK (`dc_boot` md5 `e10c53c2…`) | 2026-08-07 |
| Manual Flycast launch Soulcalibur CHD | **FAIL** — `Invalid CHD file` | 2026-08-07 |
| Soulcalibur CHD md5 vs Fightcade DB | **MISMATCH** have `0df05e8e…` expect `8754066b…` | 2026-08-07 |
| Restored missing `/var/data/flycast_roms.json` | copied from app `emulator/flycast/flycast_roms.json` | 2026-08-07 |

### Log findings (Soulcalibur exit)

- `logs/fcade.log`: `Playing: fcade://play/flycast/flycast_dc_soulclbr`
- `logs/flycast.log`: **empty**
- `data/frm.log`: `Error: Missing file [/app/fightcade/Fightcade/emulator/flycast_roms.json]` (frm checkrom; fotns still played earlier)
- `emu.cfg`: `UseReios = no` (real BIOS required)
- Emulator `data` → `/var/data/config/flycast/data` — **had no `dc_boot.bin`**
- `ROMs/flycast/data` → `bios/dc` is **not** the path Flycast reads for Dreamcast BIOS

[Inference] Dreamcast needs BIOS in `config/flycast/data/`; Naomi/AW can use bios zips already in their game folders. `ROMs/flycast/data` alone is insufficient on Flatpak.
