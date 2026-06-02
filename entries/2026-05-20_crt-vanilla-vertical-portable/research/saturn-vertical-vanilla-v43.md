# Sega Saturn — vertical cabinet on vanilla Batocera v43

**Session:** [Vanilla vertical portable](../plan.md)
**Default core (Batocera x86_64, locked here):** `libretro` + **`beetle-saturn`** (`configgen-defaults-x86_64.yml`).
**Related:** [PC Engine vertical](pcengine-vertical-vanilla-v43.md), [SNES vertical](snes-vertical-vanilla-v43.md), [Vectrex vertical](vectrex-vertical-vanilla-v43.md), [Dreamcast vertical](dreamcast-vertical-vanilla-v43.md) (similar state-injection pattern, but Dreamcast also needs per-game rotation cfgs — Saturn does not), [NAOMI vertical](naomi-vertical-vanilla-v43.md) (rotation-only, no state-injection — opposite end of the complexity scale from Saturn), [PSX vertical](psx-vertical-vanilla-v43.md) (rotation + fill + per-game custom viewport; no state-injection — PSX persists its own settings to memory cards), [PS2 vertical](ps2-vertical-vanilla-v43.md) (analogous bootstrap-state idea adapted for standalone PCSX2-Qt — `.p2s` instead of `.state.auto`, CLI `-statefile` instead of RA `savestate_auto_load`, `chmod 444` lock instead of `autosave=0` decoupling). Autoconfig spec: [saturn-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/saturn-vertical-autoconfig.md).

---

## Reading this from a fresh install

This doc assumes the operator has:

1. Flashed and booted **vanilla Batocera v43** on the cabinet hardware.
2. Run the **Batocera-CRT-Script v43 installer** and picked the **vertical / TATE** options. After reboot, the cabinet should have:
   - `display.rotate=1` in `/userdata/system/batocera.conf`
   - `global.videooutput=<your CRT output>` (e.g. `DP-1`)
   - `global.videomode=Boot_…` from the installer
   - The CRT display profile applied (`first_script.sh`, EDID, super-res ladder)
   - EmulationStation booting vertically at the cabinet's native CRT resolution
3. Copied Saturn **ROMs** to `/userdata/roms/saturn/` (`.chd`, `.cue/.bin`).
4. Dropped **Saturn BIOS** (regional, e.g. `saturn_bios.bin`, `mpr-17933.bin`) into `/userdata/bios/`.

Everything below adds Saturn vertical-shmup support on top of that baseline. It does not change any other system, the CRT display profile, or the global rotation; it only touches **three** Saturn keys and a save-state directory.

## Why Saturn is simpler than Dreamcast

| | Saturn (Beetle Saturn) | Dreamcast (Flycast) |
|---|------------------------|---------------------|
| **In-game TATE captured in savestate?** | Yes — Saturn games store TATE / Side in Saturn RAM, which is in the `.state.auto`. Loading the state restores the in-game option exactly. | Sometimes — see Dreamcast doc. |
| **RetroArch rotation needed?** | No. Saturn's TATE flips the framebuffer's contents itself; v43's CRT Script geometry handles screen layout. | Yes for some titles. See Dreamcast doc. |
| **Per-game rotation cfg needed?** | No. | Yes for in-game-TATE titles (`video_rotation = "0"`). |
| **Fill geometry needed?** | No (v43 default fills correctly for Saturn). | Yes (`ratio=full` + `video_force_aspect=false`). |
| **Number of `batocera.conf` keys** | **3** (autosave decouple) | **6** (autosave decouple + rotation + fill) |

For Saturn the entire recipe is state-injection + three keys.

---

## Deployed policy (cabinet-tested, 2026-05-22)

**Cabinets:** v43 vanilla at `10.23.6.210` (`batocera.local`); Myzar source at `10.23.6.211`.

**Decision:** **Do not** add Saturn geometry / rotation keys to `batocera.conf` on v43. The v43 + CRT Script display profile already produces the correct Saturn rotation and screen size on this cabinet. The Myzar `Beetle Saturn/*.cfg` per-game files (with `video_rotation`, `custom_viewport_*`, `aspect_ratio_index = "24"`, `video_force_aspect = "false"`) are **explicitly skipped** because their geometry is wrong for this hardware.

**Mechanism:** decoupled **autoload-only** RetroArch savestate keys + a curated set of `.state.auto` files captured on Myzar past the Sega/Saturn/game intros and with the in-game **Side / TATE** option already set. The decouple is required because Batocera's normal `<system>.autosave=1` enables **both** autoload **and** autosave-on-quit, which would overwrite the curated baseline the first time a player quit.

### `batocera.conf` (v43, `10.23.6.210`)

```ini
# Saturn: state-injection with pristine baseline preserved (geometry untouched)
saturn.autosave=0
saturn.retroarch.savestate_auto_load=true
saturn.retroarch.savestate_auto_save=false
```

Set via:

```bash
batocera-settings-set saturn.autosave 0
batocera-settings-set saturn.retroarch.savestate_auto_load true
batocera-settings-set saturn.retroarch.savestate_auto_save false
```

`saturn.autosave=0` makes configgen set both `savestate_auto_save = false` and `savestate_auto_load = false`. The two explicit `retroarch.*` pass-through keys then flip only the **load** side back to `true`. Net effect: RA loads `<Game>.state.auto` on launch, never writes it on exit (see `libretroConfig.py` `autosave` block + per-system `retroarch.*` pass-through).

### Save directory layout (`/userdata/saves/saturn/`)

For each seeded title:

| File | Purpose |
|------|---------|
| `<Game>.state.auto` | RetroArch savestate restored on launch (skips splash, lands in-game with TATE already set) |
| `<Game>.state.auto.png` | RA preview thumbnail (cosmetic) |
| `<Game>.bcr` / `.bkr` / `.smpc` | Beetle Saturn backup RAM trio (untouched by this deploy; pre-existing on v43) |

## Why the in-game TATE persists across launches

The Saturn TATE / Side option for these titles is **not** stored as a RetroArch frontend key. It lives in the **Saturn's game RAM** at the moment the savestate was captured. RA savestates snapshot core RAM + CPU registers, so reloading `.state.auto` restores the in-game option exactly as it was when the snapshot was made. RA's own `video_rotation` is **not** in the savestate, so the cabinet's existing rotation policy stays in charge.

## Deployment (2026-05-22)

1. Pulled all `*.state.auto` and `*.state.auto.png` from Myzar `10.23.6.211:/userdata/saves/saturn/` (also captured `.bcr/.bkr/.smpc/.state1` for completeness).
2. Pushed only the **state.auto pairs** to v43 `10.23.6.210:/userdata/saves/saturn/` with rsync include/exclude filter:

   ```bash
   rsync -av --include='*.state.auto' --include='*.state.auto.png' --exclude='*' \
     root@10.23.6.211:/userdata/saves/saturn/ \
     root@10.23.6.210:/userdata/saves/saturn/
   ```

3. `chown root:root` all `*.state.auto*` on v43.
4. Set the three Saturn keys (`saturn.autosave=0`, `saturn.retroarch.savestate_auto_load=true`, `saturn.retroarch.savestate_auto_save=false`) via `batocera-settings-set` (only Saturn; not `global.*`).
5. Verified Batsugun and Battle Garegga first; behavior confirmed by user. Rolled out to the rest in one rsync.
6. **Decouple step added 2026-05-22 (PM):** initial deploy used `saturn.autosave=1` which overwrote curated states on first quit. Switched to the three-key decoupled pattern, re-pushed all 38 `.state.auto` pairs from Myzar source, re-`chown`ed. Pristine baseline now persists across play sessions.

## Seeded titles (38)

Batsugun, Battle Garegga, Blast Wind (Japan), Crimewave (USA), Detana Twinbee Yahoo! Deluxe Pack (Japan), DoDonPachi, DonPachi, Galactic Attack, Game Tengoku - The Game Paradise!, Gekirindan, Guardian Force, Gun Frontier, Gunbird, ImageFight & Xmultiply, Kyuukyoku Tiger II Plus, Layer Section II (Japan), Mass Destruction (US), Planet Joker, Puzzle Bobble 2X, Puzzle Bobble 3, Radiant Silvergun, Sega Ages - After Burner II (Japan), Shienryuu, Shippuu Mahou Daisakusen, Skull Fang - Kuuga Gaiden, Sonic Wings Special, Soukyu Gurentai Otokuyo, Space Invaders, Steam-Heart's, Steamgear Mash, Stellar Assault SS, Strikers 1945 (Japan), Strikers 1945 II (Japan), Terra Cresta 3D, Thunder Force Gold Pack 1, Time Bokan Series Bokan to Ippatsu! Doronboo Kanpekiban, Tukai! Slot Shooting, Twinkle Star Sprites (Japan).

## Titles on Myzar without `.state.auto` (launch cold)

`Tempest 2000`, `Wing Arms`. Only `.bcr/.bkr/.smpc` existed on Myzar. They boot normally on v43; if you want intro-skip + TATE for them, play to a good point on v43 and exit — autosave will write a fresh `.state.auto` for next time.

## Hard locks for this approach to work

- **Core: `beetle-saturn` only.** Savestates are core-tied. Switching `saturn.core` to `yabasanshiro` breaks every seeded state.
- **Filename match.** `.state.auto` stem must equal the ROM stem used at launch (e.g. `Batsugun.state.auto` <-> `Batsugun.chd`).
- **Owner / perms.** Files must be readable by the user RA runs as (root on Batocera).

## Risks / gotchas

- **Mid-session progress is not saved on exit.** That is the intended behavior for arcade-style vertical shmups (curated baseline always wins). Players who want to save in the middle of a run should use a manual savestate slot (`F2` to Slot 1, etc.); manual slots are independent of `.state.auto` and not affected by these keys.
- **Manual Slot 1 not deployed.** Myzar had `<Game>.state1[.png]` for a few titles (DoDonPachi, Guardian Force). Not pushed to v43. Easy to push later if wanted.
- **Canonical copy is on the deployed cabinet.** `/userdata/saves/saturn/` on `10.23.6.210` holds the live bundle. Re-seed from Myzar `10.23.6.211` or re-capture on hardware per "Adding a new Saturn title" below.

## QA checklist

1. `batocera-settings-get saturn.autosave` returns `0`; `saturn.retroarch.savestate_auto_load` returns `true`; `saturn.retroarch.savestate_auto_save` returns `false`.
2. `ls /userdata/saves/saturn/ | grep -c state.auto$` returns `38`.
3. Launch Batsugun on v43: skip Sega/Saturn/game intro splashes, come up in TATE, on v43's correct geometry. Quit normally.
4. Re-list `Batsugun.state.auto` — size and mtime should be unchanged (RA did not overwrite).
5. Repeat for a couple of other titles.

## SSH note (`ssh-batocera.sh`)

For the two cabinets, prefix the IP explicitly so the script does not treat the command word as a hostname:

```bash
~/bin/ssh-batocera.sh 10.23.6.210 'ls /userdata/saves/saturn/ | grep state.auto'
~/bin/ssh-batocera.sh 10.23.6.211 'ls /userdata/saves/saturn/ | grep state.auto'
```

## Links

- Generator merge spec: [saturn-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/saturn-vertical-autoconfig.md)
- Myzar (source) hybrid Switchres context: [`2026-05-21_crt-myzar-dp-hybrid-switchres/debug/saturn-beetle-core-crt.md`](../../2026-05-21_crt-myzar-dp-hybrid-switchres/debug/saturn-beetle-core-crt.md) — Myzar's per-game `Beetle Saturn.cfg` geometry **not** used here.
