# BUA Fightcade Flatpak — Missing ROMs Directory

## Agent/Model Scope

Composer + ssh-batocera. Scope is Flatpak Fightcade only (ROMs path / first-run usability / install script). Not CRT, not Switchres, not the BUA Wine Fightcade add-on.

## Problem

Flatpak Fightcade (`com.fightcade.Fightcade`) on Batocera does not expose a usable main ROMs directory after download/install. Operators cannot load ROMs until they force the app to create its data tree (Ports → sign-in → room TEST → Show Hidden under `.var`). Need a durable, shareable fix so users can install Fightcade and drop Fightcade-format ROMs into normal Batocera `/userdata/roms` folders.

## Root Cause

Confirmed on batocera.local (Flatpak **2.4.2**):

1. Entrypoint `fightcade` only `mkdir -p ${DATADIR}/ROMs/{fbneo,ggpofba,snes9x,flycast}` on first launch — no console subdirs, no host ROM wiring.
2. Persistent data lives under `/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/` (hidden unless Show Hidden).
3. Symlinks out of the sandbox to `/userdata/roms/...` require Flatpak `--filesystem` overrides or files must live inside the already-allowed data tree.
4. Arcade `roms/fbneo` is flat; Fightcade also needs console subdirs under `ROMs/fbneo/` — cannot replace whole `fbneo/` with one symlink to Batocera arcade.

## Solution (current delivery plan)

Ship a **new GitHub repo** under [net-terminal-gene](https://github.com/net-terminal-gene) (proposed name: `batocera-fightcade-flatpak`), modeled on [batocera-service-sunshine-flatpak](https://github.com/Redemp/batocera-service-sunshine-flatpak):

```bash
curl -fsSL \
  https://raw.githubusercontent.com/net-terminal-gene/batocera-fightcade-flatpak/main/install.sh \
  | bash
```

### `install.sh` behavior

1. Confirm Batocera + Flatpak available; ensure Flathub remote if needed.
2. Install `com.fightcade.Fightcade` if missing; run `batocera-flatpak-update` so ES Ports picks it up.
3. Pre-create the Flatpak ROMs tree (and missing Fightcade subdirs the Flatpak does not create):
   - `ROMs/{fbneo,flycast,snes9x,ggpofba}`
   - `fbneo/{coleco,gamegear,megadrive,msx,nes,nes_fds,pce,sg1000,sgx,sms,spectrum,tg16}`
   - `flycast/{atomiswave,dreamcast,naomi,naomi2}` (+ optional `data` scaffold)
4. Symlink from existing Batocera `/userdata/roms` into that tree (idempotent; only when source dirs exist).
5. Apply Flatpak system filesystem overrides for every linked host path.
6. Optional: `diagnose` / `uninstall` helpers (no Batocera long-running service required — Fightcade launches from ES).

### Validated symlink map (batocera.local, 2026-08-07)

User confirmed launches working after manual apply.

| Fightcade path | Batocera source | Method |
|----------------|-----------------|--------|
| `ROMs/fbneo/*.zip` | `/userdata/roms/fbneo/*.zip` | Per-zip symlinks (arcade root stays a real dir) |
| `ROMs/fbneo/megadrive` | `/userdata/roms/megadrive` | Dir symlink |
| `ROMs/fbneo/nes` | `/userdata/roms/nes` | Dir symlink |
| `ROMs/fbneo/gamegear` | `/userdata/roms/gamegear` | Dir symlink |
| `ROMs/fbneo/coleco` | `/userdata/roms/colecovision` | Dir symlink |
| `ROMs/fbneo/pce` | `/userdata/roms/pcengine` | Dir symlink |
| `ROMs/fbneo/sg1000` | `/userdata/roms/sg1000` | Dir symlink |
| `ROMs/fbneo/msx` | `/userdata/roms/msx1` | Dir symlink |
| `ROMs/flycast/atomiswave` | `/userdata/roms/atomiswave` | Dir symlink |
| `ROMs/flycast/naomi` | `/userdata/roms/naomi` | Dir symlink |
| `ROMs/flycast/naomi2` | `/userdata/roms/naomi2` | Dir symlink |
| `ROMs/flycast/dreamcast` | `/userdata/roms/dreamcast` | Dir symlink |
| `ROMs/snes9x` | `/userdata/roms/snes` | Dir symlink |

Empty scaffolds when Batocera source missing: e.g. `nes_fds`, `sms`←`mastersystem`, `spectrum`←`zxspectrum`, `sgx`←`supergrafx`, `tg16`.

### README constraints (must document)

- Users drop **Fightcade/FBNeo shortname `.zip` sets** (and matching Flycast layouts) into the mapped Batocera folders.
- Normal Batocera long-title / `.7z` console dumps will not satisfy Fightcade.
- Dreamcast still needs Fightcade-valid CHDs + BIOS in Flycast’s real data path (`config/flycast/data`); symlink alone is not enough for bad dumps.
- Idempotent re-runs: create missing dirs, refresh managed symlinks, do not wipe unrelated user files under `ROMs/`.

## Implementation checklist (repo)

- [ ] Create `net-terminal-gene/batocera-fightcade-flatpak` (or final name)
- [ ] Port Sunshine-style `install.sh` skeleton (prereqs, Flatpak install, logging)
- [ ] Encode ROMs mkdir scaffold + symlink map + overrides
- [ ] Optional `diagnose` / `uninstall`
- [ ] README: curl one-liner, mapping table, ROM format warnings, QA steps
- [ ] Test on batocera.local: fresh path or re-run over existing install

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Manual on batocera.local | `.../data/ROMs/**` + Flatpak overrides | Symlinks + overrides validated (see `debug/`) |
| `net-terminal-gene/batocera-fightcade-flatpak` (planned) | `install.sh`, README, helpers | Encode validated recipe |

## Validation

- [x] Fresh Flatpak Fightcade: `data/ROMs` only after first launch mkdir
- [x] Symlink flycast systems + snes9x; Naomi / Atomiswave PASS
- [x] FBNeo arcade + console symlinks; user reports Fightcade working
- [ ] Dreamcast: blocked by wrong CHD MD5s (out of install-script critical path)
- [ ] Publish install script repo and re-validate via `curl \| bash` on Batocera
