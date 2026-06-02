# Sega NAOMI — vertical cabinet on vanilla Batocera v43

**Session:** [Vanilla vertical portable](../plan.md)
**Default core (Batocera x86_64, locked here):** `libretro` + **`flycast`** (`configgen-defaults-x86_64.yml`). Same core as Dreamcast; per-ROM cfgs share the `Flycast/` directory namespace but the filenames do not collide because NAOMI uses MAME-style short names (`ikaruga.cfg`) and Dreamcast uses ROM display names (`Ikaruga (Japan).cfg`).
**Related:** [Dreamcast vertical](dreamcast-vertical-vanilla-v43.md) (same core; this doc inherits Dreamcast's rotation conventions but does NOT use state-injection), [Saturn vertical](saturn-vertical-vanilla-v43.md), [SNES vertical](snes-vertical-vanilla-v43.md), [PC Engine vertical](pcengine-vertical-vanilla-v43.md), [Vectrex vertical](vectrex-vertical-vanilla-v43.md), [PSX vertical](psx-vertical-vanilla-v43.md) (next-up-the-ladder of complexity — NAOMI needs only rotation; PSX adds fill keys + per-game custom viewport for Cave-family titles, no state-injection); autoconfig spec [naomi-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/naomi-vertical-autoconfig.md).

---

## Reading this from a fresh install

This doc assumes the operator has:

1. Flashed and booted **vanilla Batocera v43** on the cabinet hardware.
2. Run the **Batocera-CRT-Script v43 installer** and picked the **vertical / TATE** options. After reboot the cabinet should have:
   - `display.rotate=1` in `/userdata/system/batocera.conf`
   - `global.videooutput=<your CRT output>` (e.g. `DP-1`)
   - `global.videomode=Boot_…` from the installer
   - The CRT display profile applied (`first_script.sh`, EDID, super-res ladder)
   - EmulationStation booting vertically at the cabinet's native CRT resolution
3. Copied NAOMI ROM zips to `/userdata/roms/naomi/`.
4. Dropped the **NAOMI BIOS** at `/userdata/roms/naomi/naomi.zip` (note: NAOMI BIOS lives in the ROM directory, not in `/userdata/bios/` — different from Dreamcast).

Everything below adds NAOMI vertical-shmup support on top of that baseline. It does not change any other system, the CRT display profile, or the global rotation. **As of 2026-05-22 it adds exactly ONE key** to `batocera.conf`.

---

## Why NAOMI is the simplest of the five vertical recipes

| Concern | NAOMI | Dreamcast | Saturn |
|---------|-------|-----------|--------|
| Intro / splash to skip? | **No** — arcade ROMs boot straight to attract mode, "Insert Coin" plays the game | Yes (Sega/Dreamcast logo + game-specific intros) | Yes (Sega/Saturn logo + game-specific intros) |
| Need curated savestates? | **No** — there is nothing to skip | Yes (skip splashes, land in-game) | Yes (skip splashes, land in-game) |
| In-game TATE storage | **NVRAM file** (`/userdata/saves/naomi/reicast/<rom>.zip.nvmem`), auto-created on first launch, persists between sessions | Dreamcast RAM at the moment of state capture | Saturn RAM at the moment of state capture |
| Default render orientation on a fresh NVRAM | Horizontal (NAOMI service-mode TATE defaults to off) | Horizontal | Game-specific |
| Number of `<system>.*` keys needed | **1** (rotation only, as of cabinet test) | 6 (rotation + fill + decoupled autoload + autosave-off) | 3 (decoupled autoload + autosave-off) |
| Per-game cfgs needed | Possibly — only for ROMs whose NVRAM ends up TATE-on (mirrors Dreamcast in-game-TATE pattern); **none discovered yet on this roster** | 9 (in-game-TATE-on titles override system-wide `=3` to `=0`) | None |

NAOMI's simplicity comes from arcade-ROM design: no splash to skip, default service-mode is horizontal, NVRAM persists across launches.

---

## All the configuration (cabinet-tested 2026-05-22)

### `batocera.conf` — one key

Append to `/userdata/system/batocera.conf` (or set via `batocera-settings-set`):

```ini
# NAOMI vertical CRT (cabinet-tested 2026-05-22 with Ikaruga on v43 + CRT Script)
naomi.retroarch.video_rotation=3
```

Set via:

```bash
batocera-settings-set naomi.retroarch.video_rotation 3
```

What this does:

| Key | Effect |
|-----|--------|
| `naomi.retroarch.video_rotation=3` | **System-wide rotation = 270° CCW.** Writes `video_rotation = 3` into `retroarchcustom.cfg` at every NAOMI launch. Correct polarity for this cabinet's mount. **On a cabinet mounted the opposite way, use `=1`** (90° CW). |

That is the only key required for the cabinet-tested behavior. No `naomi.ratio=full`, no `video_force_aspect=false`, no autosave decoupling. NAOMI ROMs render at 640×480 native, which matches the cabinet's super-res after RA rotates the framebuffer.

### Per-game rotation overrides — **none on this cabinet (as of 2026-05-22)**

If a NAOMI ROM ends up rendering double-rotated (lying on its side) after the system-wide key is applied, the cause is the same as Dreamcast's in-game-TATE problem: the game's NVRAM has the service-mode TATE flag set, so the game already rotates internally, and RA's `=3` is rotating again. The fix mirrors Dreamcast:

```bash
CFG=/userdata/system/configs/retroarch/config/Flycast
mkdir -p "$CFG"
printf 'video_rotation = "0"\n' > "$CFG/<rom_stem>.cfg"   # e.g. trizeal.cfg
chmod 644 "$CFG/<rom_stem>.cfg"
chown -R root:root "$CFG"
```

Note: NAOMI ROM stems are **MAME-style short names** (`trizeal`, `ikaruga`, `karous`), not Dreamcast-style display names. The `.cfg` filename must match the ROM stem exactly (`trizeal.zip` → `trizeal.cfg`).

A `Flycast/<naomi_rom>.cfg` and `Flycast/<dreamcast_rom>.cfg` coexist cleanly in the same directory because the stems differ.

### Why this is the same approach as Dreamcast (and why we did NOT copy Myzar's NAOMI approach)

Myzar's NAOMI cabinet uses a **core-level** rotation (`Flycast/naomi.opt` with `reicast_screen_rotation = "vertical"`) combined with `Flycast/naomi.cfg` `video_rotation = "1"` and a custom 640×960 viewport (`aspect_ratio_index = "24"`, `custom_viewport_width = "640"`, `custom_viewport_height = "960"`). It also seeds 12 `.state.auto` files for NAOMI.

We did NOT adopt that path on this cabinet because:

- **Rotation polarity is opposite.** Myzar's mount uses `=1`; this cabinet uses `=3`.
- **Core option rotation puts logic inside the core.** The Dreamcast deploy already established a working RetroArch-level rotation pattern; reusing it for NAOMI keeps both Flycast-using systems consistent.
- **Custom viewport is unnecessary here.** NAOMI's native 640×480 fills the rotated super-res without needing an explicit 640×960 viewport.
- **State-injection adds files and core-tie risk for zero gameplay benefit.** Arcade ROMs have no skippable intro; "skip the intro" is not a goal for NAOMI.

---

## Per-title rotation status

Cabinet roster (12 ROMs in `/userdata/roms/naomi/`):

| Title | ROM file | Cabinet status (2026-05-22) | Notes |
|-------|----------|-----------------------------|-------|
| Ikaruga | `ikaruga.zip` | **PASS** with system-wide `=3` | Tested via launch on 10.23.6.210; correctly vertical, fullscreen |
| Karous | `karous.zip` | Pending per-title launch test | Likely PASS with `=3` (fresh NVRAM defaults to TATE off); if double-rotated, add `Flycast/karous.cfg` with `video_rotation = "0"` |
| Psyvariar 2 | `psyvar2.zip` | Pending | Same expected behavior as above |
| Radirgy | `radirgy.zip` | Pending | Same |
| Radirgy NoaH | `radirgyn.zip` | Pending | Same |
| Shikigami no Shiro II | `shikgam2.zip` | Pending | Same |
| Trigger Heart Exelica | `trgheart.zip` | Pending | Same |
| Trizeal | `trizeal.zip` | Pending | Same |
| Under Defeat | `undefeat.zip` | Pending | Same |
| Illvelo | `illvelo.zip` | Pending | Same |
| Mamoru-kun wa Norowarete Shimatta! | `mamonoro.zip` | Pending | Same |
| Senko no Ronde 2 (a.k.a. SL2007) | `sl2007.zip` | Pending | Same |

Per-title test procedure if any of the pending titles render wrong:

1. Launch the title once with the system-wide key only. Observe orientation.
2. If correctly vertical (like Ikaruga) → done, no per-game cfg needed.
3. If double-rotated (lying on its side) → game's NVRAM has TATE on. Either:
   - Add a per-game `Flycast/<stem>.cfg` with `video_rotation = "0"` (matches Dreamcast in-game-TATE pattern), OR
   - Enter the game's service menu (Test button) and toggle TATE off; NVRAM saves automatically. Use whichever feels more natural to the operator. The per-game cfg is more portable across NVRAM resets.

---

## Adding a new NAOMI title later

1. Drop the ROM into `/userdata/roms/naomi/`. Confirm the NAOMI BIOS (`naomi.zip`) is also present in that directory.
2. Launch and observe orientation.
3. If correct → done. The first launch creates `/userdata/saves/naomi/reicast/<rom>.zip.nvmem` automatically.
4. If double-rotated → see the per-title test procedure above.

The NVRAM file persists service-mode settings across reboots. If a user-visible setting (TATE, region, difficulty) needs changing later, hold the Test / Service hotkey at boot to enter the NAOMI service menu; changes saved there go into the NVRAM.

---

## Save / NVRAM directory layout

After Ikaruga has been launched once on this cabinet:

| File | Purpose |
|------|---------|
| `/userdata/saves/naomi/ikaruga.B1.bin` | NAOMI cartridge bank dump (auto-created by Flycast on first launch; do not delete) |
| `/userdata/saves/naomi/ikaruga.C1.bin` | NAOMI cartridge bank dump (auto-created; do not delete) |
| `/userdata/saves/naomi/reicast/ikaruga.zip.nvmem` | NAOMI NVRAM — service-mode settings, hi-scores, free-play flag, TATE flag |

`.state.auto` files would also live in `/userdata/saves/naomi/` but **none are deployed by this recipe** because there is nothing to skip.

---

## Hard locks for this approach to work

- **Core: `flycast` only.** Same lock as Dreamcast. NAOMI on `flycastvl` or any future fork has different config layout and would require a separate recipe.
- **NAOMI BIOS at `/userdata/roms/naomi/naomi.zip`.** Without it Flycast refuses to boot any NAOMI ROM. (BIOS location is different from Dreamcast, which expects `dc_boot.bin` + `dc_flash.bin` in `/userdata/bios/`.)
- **Rotation polarity.** `=3` assumes the cabinet is mounted with the screen's bottom on the cabinet's right (270° CCW logical rotation). Mirrored cabinets use `=1`. Any future per-game `=0` overrides are mount-independent because they leave game-internal TATE alone to drive rotation.
- **Geometry.** This recipe assumes v43 + CRT Script has already produced correct NAOMI resolution. The single key above adds rotation on top of that geometry; it does not set videomode. If a fresh CRT Script install produces wrong NAOMI geometry, fix that first (separately from this recipe).
- **Same `Flycast/` config dir as Dreamcast.** When adding per-game cfgs, double-check that no Dreamcast cfg with an overlapping stem exists (the chance is essentially zero — Dreamcast uses display names, NAOMI uses MAME names — but worth a `ls` before writing).

---

## Risks / gotchas

- **NVRAM state varies between installs.** A NAOMI NVRAM auto-generated on this cabinet may have TATE off; the same ROM's NVRAM generated on a different cabinet (or restored from a backup) may have TATE on. The per-title rotation matrix is therefore NVRAM-dependent. Treat the table above as "this cabinet, fresh NVRAM defaults"; re-run the per-title test if NVRAM was sourced elsewhere.
- **Service-mode entry is hardware-dependent.** The NAOMI service-mode hotkey defaults vary; on Batocera Flycast it is usually mapped to `Tab` + a controller combo. Not all cabinets expose a Test button. Per-game `=0` cfg is the more reliable fix for stuck-TATE-on NVRAMs.
- **No savestate fallback.** Unlike Saturn/Dreamcast, this recipe has no curated "land mid-game in TATE" feature. The arcade attract → coin → play loop is the intended UX. If a ROM has a long unskippable boot, it remains long.
- **Wrong-direction rotation on mirrored cabinets is silent.** `=3` produces a usable rotation in only one polarity; the other comes up upside-down. There is no automatic detection — see the rotation polarity note above.

---

## QA checklist (current as of 2026-05-22)

1. **Key present:**
   ```bash
   batocera-settings-get naomi.retroarch.video_rotation        # → 3
   ```
2. **BIOS present:**
   ```bash
   test -f /userdata/roms/naomi/naomi.zip && echo OK
   ```
3. **Launch Ikaruga from EmulationStation → NAOMI:** correctly vertical, fullscreen, attract mode plays, coin/start enters game in TATE.
4. **(Optional sweep)** Launch each of the other 11 NAOMI ROMs once. Note any that come up double-rotated; add per-game `Flycast/<stem>.cfg` with `video_rotation = "0"` for those, retest.
5. **No per-game cfgs needed for clean cabinets:**
   ```bash
   ls /userdata/system/configs/retroarch/config/Flycast/ | grep -E '^(ikaruga|karous|psyvar2|radirgy|radirgyn|shikgam2|trgheart|trizeal|undefeat|illvelo|mamonoro|sl2007)\.cfg$'
   # → expect empty unless a per-title fix was needed
   ```

---

## SSH note (`ssh-batocera.sh`)

```bash
~/bin/ssh-batocera.sh 10.23.6.210 'batocera-settings-get naomi.retroarch.video_rotation'
~/bin/ssh-batocera.sh 10.23.6.210 'ls /userdata/saves/naomi/reicast/'
```

NAOMI ROM names contain no spaces / parens / commas (MAME-style 8.3-like names), so per-game cfg generation does not face the quoting hazards that Dreamcast does. A one-line SSH `printf` works:

```bash
~/bin/ssh-batocera.sh 10.23.6.210 'printf "video_rotation = \"0\"\n" > /userdata/system/configs/retroarch/config/Flycast/trizeal.cfg && chmod 644 $_'
```

---

## Links

- Generator merge spec: [naomi-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/naomi-vertical-autoconfig.md)
- Dreamcast (same core, more complex deploy): [dreamcast-vertical-vanilla-v43.md](dreamcast-vertical-vanilla-v43.md)
- Sibling vertical specs: [pcengine-vertical-vanilla-v43.md](pcengine-vertical-vanilla-v43.md), [snes-vertical-vanilla-v43.md](snes-vertical-vanilla-v43.md), [vectrex-vertical-vanilla-v43.md](vectrex-vertical-vanilla-v43.md), [saturn-vertical-vanilla-v43.md](saturn-vertical-vanilla-v43.md)
- Myzar source reference (different polarity + `reicast_screen_rotation=vertical` core option + 12 NAOMI `.state.auto` files): [`2026-05-21_crt-myzar-dp-hybrid-switchres/research/emulator-expected-resolutions.md`](../../2026-05-21_crt-myzar-dp-hybrid-switchres/research/emulator-expected-resolutions.md)
