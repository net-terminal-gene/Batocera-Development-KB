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

### Design addition (2026-08-08): auto-refresh game hook

Not in the original plan. Verified in `batocera.linux` sources that `emulatorlauncher.py` synchronously runs every executable in `/userdata/system/scripts` as `<script> gameStart <system> <emulator> <core> <rom>` before launch, and the Flatpak generator goes through the same path. A hook (`fightcade-game-hook`) matches the rom file contents (`com.fightcade.Fightcade`) and runs `fightcade-roms-sync --quiet`, so zips added to `/userdata/roms/fbneo` are linked automatically before every Fightcade launch — no re-run of the installer needed.

### Design addition (2026-08-08): artwork + gamelist install

`batocera-flatpak-update` only ships the app icon (`images/Fightcade.png`) and its ES API entry uses that as `<image>`. The repo now ships the splash artwork `Fightcade-image.png` (1679x943, pulled from the validated device) and `install.sh` wires it up: creates `gamelist.xml` if missing, appends a Fightcade `<game>` entry if the file exists without one, leaves an existing entry untouched, then POSTs the entry to ES's `/addgames/flatpak` HTTP API so a running ES shows the artwork immediately (ES merges by `<path>` and persists itself).

### Design addition (2026-08-09): CRT Switchres support (port of BUA wrapper)

Port of the BUA Wine Fightcade add-on's `switchres_fightcade_wrap.sh` (BUA commits `f40b58a`, `34c3688`). The BUA version intercepts `fcade://` URLs via a host `~/bin/xdg-open` shim; the Flatpak bundles its own read-only `xdg-open` inside `/app`, so that trigger doesn't port. Instead, a host-side daemon (`fightcade-crt-watch`) is started by the gameStart hook and stopped on gameStop. It tails `fcade.log` (host-visible at `.../data/logs/fcade.log`, per research/01 inventory) for `fcade://play/<emu>/<rom>` lines, resolves native dims (same MAME `-listxml` lookup + console prefix table as BUA, incl. Neo Geo 304px correction), patches the emulator configs (host-visible: `config/fcadefbneo/fcadefbneo.ini`, `config/snes9x/fcadesnes9x.conf`, `config/flycast/emu.cfg`), applies `switchres W H R -s -k` with the configured monitor profile, monitors the emulator (Flatpak Wine processes are host-`pgrep`-visible; windows render on host X), and restores configs + display via the BUA multi-fallback restore engine. Gating identical to BUA: xorg display mode + width < 1024, with `fightcade-switchres.disable` / `.force` control files. Known limitation: ggpofba (FC1) ini lives in the read-only app image — FC1 gets the modeline switch but no fullscreen ini patch.

## Implementation checklist (repo)

- [x] Local repo built at `~/batocera-fightcade-flatpak` (2026-08-08); GitHub repo deferred until tested
- [x] Port Sunshine-style `install.sh` skeleton (prereqs, Flatpak install, logging)
- [x] Encode ROMs mkdir scaffold + symlink map + overrides
- [x] `fightcade-diagnose` / `uninstall.sh`
- [x] `fightcade-game-hook` auto-refresh on gameStart (design addition, see above)
- [x] Artwork + gamelist.xml install (design addition, see above)
- [x] `_fightcade.txt` requirement notes in each linked `roms/<system>` folder (`_info.txt` style; written by sync, removed by uninstall; validated on device 2026-08-08)
- [x] README: curl one-liner, mapping table, ROM format warnings, artwork, QA steps
- [x] Test on batocera.local (2026-08-08, fresh flash): full install path incl. Flathub bootstrap + Fightcade install PASS; diagnose all PASS; idempotent re-run PASS; gameStart hook link/prune PASS; gamelist create/append/skip all PASS; user confirmed games launch with artwork
- [x] CRT Switchres watcher `fightcade-crt-watch` + hook start/stop wiring (design addition, see above; 2026-08-09, not yet device-tested)
- [ ] Test CRT path on a CRT (xorg, <1024 menu res): modeline switch on TEST GAME, restore on exit, gameStop safety restore
- [x] Create `net-terminal-gene/batocera-fightcade-flatpak` on GitHub and push (2026-08-09, commit `9a44f14`; raw install URL verified live)

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
