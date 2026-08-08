# Research — BUA Fightcade Flatpak — Missing ROMs Directory

## Findings

| Doc | Contents |
|-----|----------|
| **[01-fightcade-flatpak-inventory.md](01-fightcade-flatpak-inventory.md)** | Host inventory + missing ROMs bug |
| **[02-target-roms-layout.md](02-target-roms-layout.md)** | Golden layout from `/Volumes/Batocera/SETUP/fightcade/` — folders + file types |
| **[03-batocera-fbneo-symlink-feasibility.md](03-batocera-fbneo-symlink-feasibility.md)** | `/userdata/roms/fbneo` vs Fightcade fbneo — arcade match; symlink + sandbox notes |
| **[04-batocera-flycast-systems-vs-fightcade.md](04-batocera-flycast-systems-vs-fightcade.md)** | Batocera dreamcast/naomi/naomi2/atomiswave `_info.txt` vs Fightcade `flycast/` |
| **[05-batocera-snes-vs-fightcade-snes9x.md](05-batocera-snes-vs-fightcade-snes9x.md)** | `roms/snes` vs Fightcade `snes9x` — symlink OK (Fightcade zip set) |
| **[06-fightcade-dreamcast-required-hashes.md](06-fightcade-dreamcast-required-hashes.md)** | Fightcade DC filenames/MD5s + local mismatch audit |
| **[07-fbneo-megadrive.md](07-fbneo-megadrive.md)** | FBNeo MD: Batocera `roms/megadrive` unusable; seed from NAS SETUP zips |

### Bug summary

- Flatpak Fightcade **2.4.2** installed; ES stub at `/userdata/roms/flatpak/Fightcade.flatpak`.
- Persistent ROMs: `.../.var/app/com.fightcade.Fightcade/data/ROMs` — created only on first `fightcade` launch.
- At SSH capture, `.var` tree was missing; app-bundled `ROMs/` is shortcuts only.

### Target ROMs layout (SETUP → Flatpak)

```
ROMs/fbneo/     ← arcade .zip + console subdirs (all .zip)
ROMs/flycast/   ← atomiswave, data (BIOS), dreamcast, naomi, naomi2 (.zip / .chd / .bin)
ROMs/snes9x/    ← flat .zip only
ROMs/ggpofba/   ← Flatpak mkdir; not in SETUP
```

### Out of scope

CRT, Switchres, and the BUA Wine/Electron Fightcade add-on.

### Validation so far

- [x] Symlinked flycast/{atomiswave,dreamcast,naomi,naomi2} + snes9x; Flatpak filesystem overrides — see `debug/01-symlinks-applied.md`
- [x] Naomi / Atomiswave launches — **PASS** (user)
- [x] FBNeo arcade + console symlinks — see `debug/02-fbneo-symlinks-applied.md`; user reports Fightcade working

### Next probes

- [x] Symlink flycast + snes9x; Naomi / Atomiswave PASS (user)
- [x] FBNeo arcade (per-zip) + console dir symlinks; user reports working
- [ ] Publish `net-terminal-gene/batocera-fightcade-flatpak` install script (see `plan.md`)
- [ ] Dreamcast CHD MD5 mismatch remains a content problem, not an install-script blocker
