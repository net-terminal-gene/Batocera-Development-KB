# Sega Dreamcast — vertical cabinet on vanilla Batocera v43

**Session:** [Vanilla vertical portable](../plan.md)
**Default core (Batocera x86_64, locked here):** `libretro` + **`flycast`** (`configgen-defaults-x86_64.yml`).
**Related:** [Saturn vertical](saturn-vertical-vanilla-v43.md) (similar state-injection pattern; Saturn does NOT need per-game rotation cfgs), [NAOMI vertical](naomi-vertical-vanilla-v43.md) (same `flycast` core; NAOMI is rotation-only — no state-injection — but shares the `Flycast/` per-game cfg dir; NAOMI stems are MAME short names so no collision), [PSX vertical](psx-vertical-vanilla-v43.md) (similar rotation + fill triplet, and similar per-game-cfg pattern for in-game-TATE titles — but PSX uses full custom viewport, not just rotation kill, and PSX skips state-injection because memory cards persist player choices), [PS2 vertical](ps2-vertical-vanilla-v43.md) (analogous bootstrap-state idea — operator captures the launch spot once and the cabinet auto-loads it on every launch — but PS2 is on standalone PCSX2-Qt, not libretro: `.p2s` instead of `.state.auto`, PCSX2-Qt CLI `-statefile` instead of RA `savestate_auto_load`, `chmod 444` lock instead of `autosave=0` decoupling), [SNES vertical](snes-vertical-vanilla-v43.md), [PC Engine vertical](pcengine-vertical-vanilla-v43.md), [Vectrex vertical](vectrex-vertical-vanilla-v43.md), autoconfig spec [dreamcast-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/dreamcast-vertical-autoconfig.md).

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
3. Copied Dreamcast **ROMs** to `/userdata/roms/dreamcast/` (`.chd`, `.cdi`, `.gdi`).
4. Dropped **Dreamcast BIOS** (`dc_boot.bin`, `dc_flash.bin`) into `/userdata/bios/`.

Everything below adds Dreamcast vertical-shmup support on top of that baseline. It does not change any other system, the CRT display profile, or the global rotation; it only touches the five Dreamcast keys, a few save files, and a small per-game cfg directory.

---

## Why Dreamcast needs three layers (and Saturn needs only one)

| Layer | Saturn (Beetle Saturn) | Dreamcast (Flycast) |
|-------|------------------------|---------------------|
| **In-game TATE captured in savestate?** | Yes — Saturn games store TATE / Side in Saturn RAM, which is in the `.state.auto`. Loading the state restores in-game TATE. | Sometimes. Dreamcast titles with an in-game TATE menu (Ikaruga, Karous, NEO XYX, …) keep that flag in DC RAM, so it is captured. Titles without an in-game TATE menu never rotate themselves. |
| **RetroArch rotation needed?** | No. Saturn's TATE rotates the framebuffer's *contents*, and v43's CRT Script geometry handles the rest. | Yes for titles that always render horizontal (RA does the rotation), No for titles whose in-game TATE rotates the contents (RA must stay at 0 or it double-rotates). |
| **Per-game cfg needed?** | No. Just the savestate. | Yes for in-game-TATE titles, to clear the system-wide rotation back to 0. |
| **Fill geometry needed?** | No (v43 default fills correctly). | Yes — `ratio=full` + `video_force_aspect=false` (rotated 640×480 would otherwise letterbox inside the active super-res). |

The Dreamcast deploy therefore has **three** independent pieces:

1. **System-wide `dreamcast.*` keys** in `batocera.conf`: rotation, fill, and decoupled autoload-only savestates.
2. **A `.state.auto` per title** seeded from a curated source (skips Sega/Dreamcast boot + game intros, leaves the in-game options as the source captured them).
3. **Per-game `Flycast/<stem>.cfg`** for the titles whose savestate has in-game TATE on — sets `video_rotation = "0"` so RA does not double-rotate.

Bullets 1 and 2 are bulk; bullet 3 is a hand-curated list of 9 titles on this roster.

---

## All the configuration

### 1. `batocera.conf` — five system-wide keys

Append to `/userdata/system/batocera.conf` (or set via `batocera-settings-set`):

```ini
# Dreamcast vertical CRT (cabinet-tested 2026-05-22 on v43 + CRT Script)
dreamcast.autosave=0
dreamcast.ratio=full
dreamcast.retroarch.video_force_aspect=false
dreamcast.retroarch.video_rotation=3
dreamcast.retroarch.savestate_auto_load=true
dreamcast.retroarch.savestate_auto_save=false
```

Set via:

```bash
batocera-settings-set dreamcast.autosave 0
batocera-settings-set dreamcast.ratio full
batocera-settings-set dreamcast.retroarch.video_force_aspect false
batocera-settings-set dreamcast.retroarch.video_rotation 3
batocera-settings-set dreamcast.retroarch.savestate_auto_load true
batocera-settings-set dreamcast.retroarch.savestate_auto_save false
```

What each key does:

| Key | Effect |
|-----|--------|
| `dreamcast.autosave=0` | Tells configgen NOT to set autosave for Dreamcast. Without this, the next two `retroarch.savestate_auto_*` keys would be overridden by the convenience block in `libretroConfig.py`. |
| `dreamcast.ratio=full` | RA aspect index `Full`. Combined with `video_force_aspect=false`, the 640×480 rotated buffer fills the active super-res with no letterbox. |
| `dreamcast.retroarch.video_force_aspect=false` | Pairs with `ratio=full`. Without this the core aspect (1.333) constrains the rotated buffer. |
| `dreamcast.retroarch.video_rotation=3` | **System-wide rotation = 270° CCW.** Writes `video_rotation = 3` into `retroarchcustom.cfg` at every Dreamcast launch. Correct polarity for this cabinet's mount. **On a cabinet mounted the opposite way, use `=1`** (90° CW). |
| `dreamcast.retroarch.savestate_auto_load=true` | RA auto-loads `<Game>.state.auto` on launch. |
| `dreamcast.retroarch.savestate_auto_save=false` | RA does NOT auto-write the state on quit. Curated baseline survives every play session. |

### 2. State files — `/userdata/saves/dreamcast/<Game>.state.auto[.png]`

For each title you want to skip the Dreamcast / game intros and start mid-game in TATE: drop a `<rom_stem>.state.auto` (and optionally `.state.auto.png` for the thumbnail) into `/userdata/saves/dreamcast/`. The stem must equal the ROM filename without extension (`Ikaruga (Japan).state.auto` for `Ikaruga (Japan).chd`).

`chown root:root` everything afterwards.

For this cabinet the states were sourced from Myzar `10.23.6.211` and deployed to `10.23.6.210`. Re-deploy from the live cabinet or Myzar source:

```bash
rsync -av --include='*.state.auto' --include='*.state.auto.png' --exclude='*' \
  root@10.23.6.210:/userdata/saves/dreamcast/ \
  root@<target>:/userdata/saves/dreamcast/
# Or from Myzar source if cabinet copy is lost:
# root@10.23.6.211:/userdata/saves/dreamcast/
ssh root@<target> 'chown root:root /userdata/saves/dreamcast/*.state.auto*'
```

For a redistributable autoconfig install, ship the equivalent bundle as an asset directory inside `Batocera-CRT-Script` and rsync it from there.

### 3. Per-game rotation overrides — `/userdata/system/configs/retroarch/config/Flycast/<stem>.cfg`

Two-tier rule for this cabinet:

- **No-TATE titles** (or in-game-TATE off in the savestate) → no per-game cfg needed. They use the system-wide `dreamcast.retroarch.video_rotation=3`.
- **In-game-TATE-on titles** → one-line per-game cfg with `video_rotation = "0"`. RA's per-content override loads AFTER `retroarchcustom.cfg` and wins, suppressing the system-wide rotation for just that title.

Generate them on the cabinet:

```bash
CFG=/userdata/system/configs/retroarch/config/Flycast
mkdir -p "$CFG"
for stem in \
  "Ikaruga (Japan)" \
  "Karous" \
  "NEO XYX" \
  "Triggerheart Exelica (Japan)" \
  "Trizeal" \
  "Under Defeat (Japan)" \
  "Radirgy" \
  "Psyvariar 2 The Will to Fabricate" \
  "Shikigami no Shiro II (Japan)"
do
  printf 'video_rotation = "0"\n' > "$CFG/${stem}.cfg"
  chmod 644 "$CFG/${stem}.cfg"
done
chown -R root:root "$CFG"
```

**Why `chmod 644`:** the default umask on Batocera makes `printf >file` create the file with mode `600`. RA running as root can still read it, but it is worth defending against any future tighter sandboxing; matching the `644` perms of every other RA cfg on the system also removes a misleading symptom during diagnosis.

**Why not write `=3` cfgs for the non-TATE titles too:** they would be redundant with the system-wide key. Writing only the `=0` overrides keeps the per-game directory minimal and self-documenting (every file is an exception).

---

## Per-title rotation matrix (cabinet-validated 2026-05-22)

The 18 vertical-shmup ROMs on this cabinet, with the rotation each one actually needs:

| Title | ROM file | RA rotation | Reason |
|-------|----------|-------------|--------|
| Chaos Field (Japan) | `Chaos Field (Japan).chd` | `3` (system-wide) | No in-game TATE option; RA rotates the horizontal frame |
| Drill | `Drill.cdi` | `3` (system-wide) | No in-game TATE |
| Fast Striker | `Fast Striker.cdi` | `3` (system-wide) | No in-game TATE |
| GigaWing 2 (USA) | `GigaWing 2 (USA).chd` | `3` (system-wide) | No in-game TATE |
| Gigawing | `Gigawing.cdi` | `3` (system-wide) | No in-game TATE |
| Gunbird 2 | `Gunbird 2.cdi` | `3` (system-wide) | No in-game TATE |
| Mars Matrix (Japan) (En,Ja) | `Mars Matrix (Japan) (En,Ja).chd` | `3` (system-wide) | In-game TATE menu exists, but Myzar's savestate captured it with TATE off |
| Twinkle Star Sprites (Japan) (En,Ja,Es) | `Twinkle Star Sprites (Japan) (En,Ja,Es).chd` | `3` (system-wide) | No in-game TATE |
| Zero Gunner 2 (Japan) (En,Ja) | `Zero Gunner 2 (Japan) (En,Ja).chd` | `3` (system-wide) | In-game TATE menu exists, but Myzar's savestate captured it with TATE off |
| Ikaruga (Japan) | `Ikaruga (Japan).chd` | `0` (per-game cfg) | In-game TATE on in savestate |
| Karous | `Karous.chd` | `0` (per-game cfg) | In-game TATE on in savestate |
| NEO XYX | `NEO XYX.cdi` | `0` (per-game cfg) | In-game TATE on in savestate |
| Psyvariar 2 The Will to Fabricate | `Psyvariar 2 The Will to Fabricate.chd` | `0` (per-game cfg) | In-game TATE on in savestate |
| Radirgy | `Radirgy.cdi` | `0` (per-game cfg) | In-game TATE on in savestate |
| Shikigami no Shiro II (Japan) | `Shikigami no Shiro II (Japan).chd` | `0` (per-game cfg) | In-game TATE on in savestate |
| Triggerheart Exelica (Japan) | `Triggerheart Exelica (Japan).cdi` | `0` (per-game cfg) | In-game TATE on in savestate |
| Trizeal | `Trizeal.chd` | `0` (per-game cfg) | In-game TATE on in savestate |
| Under Defeat (Japan) | `Under Defeat (Japan).chd` | `0` (per-game cfg) | In-game TATE on in savestate |

9 titles default-rotate, 9 titles need the per-game `=0` override.

---

## Adding a new Dreamcast title later

1. Drop the ROM into `/userdata/roms/dreamcast/`.
2. If you have a curated `.state.auto[.png]` for it, drop into `/userdata/saves/dreamcast/`, `chown root:root`.
3. Launch and watch:
   - If the game comes up correctly rotated → no per-game cfg needed (it inherits `dreamcast.retroarch.video_rotation=3`).
   - If the game comes up wrong-orientation → check the game's in-game options for a TATE / Yoko toggle, and write a per-game cfg:
     ```bash
     printf 'video_rotation = "0"\n' > "/userdata/system/configs/retroarch/config/Flycast/<rom_stem>.cfg"
     chmod 644 "/userdata/system/configs/retroarch/config/Flycast/<rom_stem>.cfg"
     ```
   - If still wrong, try `"2"` (180° flip — game-internal TATE goes the opposite direction from this cabinet's mount) or `"1"` (90° axis swap).

---

## Save / state directory layout

For each seeded title:

| File | Purpose |
|------|---------|
| `<Game>.state.auto` | RetroArch savestate restored on launch (skips Dreamcast BIOS + game intros, lands in-game) |
| `<Game>.state.auto.png` | RA preview thumbnail (cosmetic) |
| `<Game>.A1.bin` / `.B1.bin` / `.C1.bin` / `.D1.bin` | Flycast VMU save data — **not** deployed by this recipe; pre-existing files left intact. If a particular title insists on creating / reading VMU data before its `.state.auto` can load, pull the matching VMU files from the curated bundle. |

---

## Hard locks for this approach to work

- **Core: `flycast` only.** Savestates are core-tied. Switching `dreamcast.core` to `flycastvl` or `redream` breaks every seeded state.
- **Filename match.** `.state.auto` stem, `Flycast/<stem>.cfg`, and the ROM stem must all be exactly the same (preserve spaces, parens, commas verbatim — do not slugify).
- **Owner / perms.** Files readable by the user RA runs as (root on Batocera). State files `chown root:root`; per-game cfgs `chmod 644`.
- **Rotation polarity.** `=3` and per-game `=0` overrides assume the cabinet is mounted with the screen's bottom on the cabinet's right (270° CCW logical rotation). Mirrored cabinets swap `=3 → =1` system-wide and the per-game overrides may need different values too — re-test the matrix.
- **Geometry.** This recipe assumes v43 + CRT Script has already produced correct Dreamcast resolution. The five `dreamcast.*` keys above tune **fill + rotation + savestates** on top of that geometry; they do not set videomode. If a fresh CRT Script install produces wrong Dreamcast geometry, fix that first (separately from this recipe).

---

## Risks / gotchas

- **Mid-session progress is not saved on exit.** Intended for arcade vertical shmups (curated baseline always wins). Players who want to save in the middle of a run should use a manual savestate slot (`F2` to Slot 1, etc.); manual slots are independent of `.state.auto` and are not affected by `savestate_auto_save=false`.
- **VMU data not deployed by default.** First boot of a title may briefly show the Dreamcast "set time / date" prompt before the state loads. The state captures Dreamcast RAM, so the prompt is bypassed within a frame or two; if a particular title insists on a VMU save, pull `<Game>.A1.bin` etc. from the curated bundle separately.
- **Per-content overrides need a writable cfg.** Generate the per-game `.cfg` files with `chmod 644` even though root can read `600`. It removes a misleading variable during diagnosis if anything else later goes wrong.
- **In-game-TATE detection is empirical.** The list above was found by launching each suspect title and checking the orientation. Any new title with an in-game TATE menu may or may not have TATE on in its curated state. Test before adding to the `=0` list.
- **Curated bundle lives on the deployed cabinet.** `/userdata/saves/dreamcast/` on `10.23.6.210`. Re-seed from Myzar `10.23.6.211` or re-capture per title. For redistribution, package an equivalent bundle into the autoconfig asset directory.

---

## Why the per-system + per-game two-tier setup (and not just per-game cfgs everywhere)

`Flycast/<stem>.cfg` is RA's per-content override. It IS loaded for every launch (the verbose RA log shows `[Override] Game-specific overrides found at "…"` + `[Config] Appending override config: "…"`), but Batocera's launch path also writes a `video_rotation = 0` line into `retroarchcustom.cfg` (the main config RA reads via `--config`) on every launch. With only per-game cfgs, the per-content override has to win over the launch-time default for every single title — which we confirmed empirically is unreliable in some edge cases (savestate-driven re-init paths in flycast appear to revert rotation under some conditions).

Pinning rotation at the **`retroarchcustom.cfg`** layer via `dreamcast.retroarch.video_rotation=3` removes the race. The per-game cfg then only needs to fire for the 9 titles that need to override that pinned value back to 0 (kill RA rotation entirely so the game's in-game TATE is the only rotation in play).

---

## QA checklist

1. **Keys present:**
   ```bash
   batocera-settings-get dreamcast.autosave                       # → 0
   batocera-settings-get dreamcast.ratio                          # → full
   batocera-settings-get dreamcast.retroarch.video_force_aspect   # → false
   batocera-settings-get dreamcast.retroarch.video_rotation       # → 3
   batocera-settings-get dreamcast.retroarch.savestate_auto_load  # → true
   batocera-settings-get dreamcast.retroarch.savestate_auto_save  # → false
   ```
2. **State files present:** `ls /userdata/saves/dreamcast/ | grep -c state.auto$` matches your roster count (18 for this cabinet, 20 if the 2 Battle Crust variants are also in the bundle).
3. **Per-game rotation cfgs present:** `ls "/userdata/system/configs/retroarch/config/Flycast/"*.cfg | wc -l` matches the in-game-TATE roster (9 for this cabinet).
4. **Launch matrix:**
   - One no-TATE title (e.g. **Chaos Field**) → rotated correctly, intro skipped, fullscreen.
   - One in-game-TATE title that needed `=0` (e.g. **Ikaruga**) → rotated correctly via in-game TATE, no double-rotation.
   - One in-game-TATE title that did NOT need `=0` (e.g. **Mars Matrix**) → rotated correctly via system-wide `=3`.
   - Quit, relaunch any of them: state file size + mtime unchanged (RA did not overwrite).

---

## SSH note (`ssh-batocera.sh`)

For per-cabinet work prefix the IP / hostname:

```bash
~/bin/ssh-batocera.sh 10.23.6.210 'ls /userdata/saves/dreamcast/ | grep state.auto'
```

When generating per-game cfgs that contain quoted strings (`video_rotation = "0"`), write the generator script to a local file and `rsync` it to `/tmp/` on the cabinet, then SSH to `chmod +x && run`. Embedding the multi-line `printf` directly in an SSH command string is fragile (nested expect quoting eats backslashes and breaks on ROM names with parens or commas).

---

## Links

- Generator merge spec: [dreamcast-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/dreamcast-vertical-autoconfig.md)
- Saturn (same state-injection pattern, no per-game rotation cfg needed): [saturn-vertical-vanilla-v43.md](saturn-vertical-vanilla-v43.md)
- Sibling vertical specs: [pcengine-vertical-vanilla-v43.md](pcengine-vertical-vanilla-v43.md), [snes-vertical-vanilla-v43.md](snes-vertical-vanilla-v43.md), [vectrex-vertical-vanilla-v43.md](vectrex-vertical-vanilla-v43.md)
- Myzar source reference (different polarity + `reicast_screen_rotation=vertical` core option): [`2026-05-21_crt-myzar-dp-hybrid-switchres/research/emulator-expected-resolutions.md`](../../2026-05-21_crt-myzar-dp-hybrid-switchres/research/emulator-expected-resolutions.md)
