# Sony PlayStation 2 (PS2) — vertical cabinet on vanilla Batocera v43

**Session:** [Vanilla vertical portable](../plan.md)
**Default emulator (Batocera v43 x86_64, locked here):** **standalone `pcsx2` (PCSX2-Qt v2.5.229)** — NOT libretro. The libretro `pcsx2_libretro` core on v43 is built with AVX-512 instructions that crash with SIGILL on the BC250 APU; the standalone PCSX2-Qt binary works fine and is the v43 default.
**Related:** [Dreamcast vertical](dreamcast-vertical-vanilla-v43.md) (also has shmup-port titles needing per-title TATE), [NAOMI vertical](naomi-vertical-vanilla-v43.md), [PSX vertical](psx-vertical-vanilla-v43.md) (different core + state-via-memory-card pattern), [Saturn vertical](saturn-vertical-vanilla-v43.md) (state-injection precedent on libretro), [SNES vertical](snes-vertical-vanilla-v43.md), [PC Engine vertical](pcengine-vertical-vanilla-v43.md), [Vectrex vertical](vectrex-vertical-vanilla-v43.md); autoconfig spec [ps2-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/ps2-vertical-autoconfig.md).

---

## Reading this from a fresh install

This doc assumes the operator has:

1. Flashed and booted **vanilla Batocera v43** on the cabinet hardware.
2. Run the **Batocera-CRT-Script v43 installer** and picked the **vertical / TATE** options. After reboot the cabinet should have:
   - `display.rotate=1` in `/userdata/system/batocera.conf`
   - `global.videooutput=<your CRT output>` (e.g. `DP-1`)
   - `global.videomode=Boot_…` from the installer (this cabinet uses `641x480.60.00082`)
   - The CRT display profile applied (`first_script.sh`, EDID, super-res ladder)
   - EmulationStation booting vertically at the cabinet's native CRT resolution
3. Copied PS2 disc images to `/userdata/roms/ps2/` (`.chd` preferred; `.iso` / `.cso` / `.bin+cue` also supported).
4. Dropped **PS2 BIOS** into `/userdata/bios/ps2/` (e.g. `SCPH30004R.bin` European, `SCPH70012.bin` USA, `SCPH77000.bin` Japan). At least one BIOS is mandatory; PCSX2 will not boot without one. **Do NOT borrow v42-era BIOS files from a Myzar install — v42 BIOS images have caused boot loops on v43.**

Everything below adds PS2 vertical-shmup support on top of that baseline. It does not change any other system, the CRT display profile, or the global rotation. **As of 2026-05-24 it adds nine `ps2.*` system-wide keys** to `batocera.conf` plus **two per-game keys + one locked save-state file per title** for each game intended to auto-launch in TATE.

---

## Why PS2 is a new recipe class (standalone bootstrap-state)

PS2 does not fit the existing four recipe classes (geometry / state-injection / rotation-only / rotation+fill+per-game-viewport). It's a fifth class:

| Class | Examples | Mechanism |
|-------|----------|-----------|
| Geometry | PCE / SNES / Vectrex | system-wide videomode + ratio |
| State-injection (libretro) | Saturn / Dreamcast | `.state.auto` files + RA `savestate_auto_*` + `<system>.autosave=0` |
| Rotation-only | NAOMI | one `<system>.retroarch.video_rotation` key |
| Rotation + fill + per-game viewport | PSX | 3 system-wide keys + per-game `Custom` viewport cfg |
| **Standalone bootstrap-state** | **PS2** | **9 system-wide PCSX2-Qt keys + per-game `state_filename` + `state_slot` + chmod-444 lock** |

PS2 specifics:

| Concern | PS2 | PSX | Dreamcast / Saturn |
|---------|-----|-----|---------------------|
| Emulator | **standalone PCSX2-Qt** (not RetroArch) | libretro pcsx_rearmed | libretro Flycast / Beetle |
| Per-game settings format | PCSX2.ini section (via configgen `ps2.*` keys) | RA `.cfg` file under `PCSX-ReARMed/` | RA `.cfg` file under `Flycast/` or `Beetle Saturn/` |
| In-game TATE storage | **PS2 memory card** (`Mcd001.ps2` slot), persists across launches | PSX memory card (`.1.mcr`) | Dreamcast RAM (captured in `.state.auto`) / Saturn (`.state.auto`) |
| Auto-launch to play-spot | **PCSX2 `-statefile <path>` + `-stateindex <N>` CLI args** (set via `state_filename` + `state_slot` per-game keys) | n/a (PSX has no skippable splash) | RA `savestate_auto_load=true` + `.state.auto` file |
| Bootstrap save creation | **Operator: F1 mid-gameplay** | n/a | RA mid-game save (or scripted) |
| Overwrite protection | **`chmod 444` on the bootstrap `.p2s` file** | n/a | `autosave=0` + non-`.auto` filename |

The bootstrap save state is what makes PS2 zero-touch on launch. Without it, each launch sits at the PS2 BIOS animation → game splash → main menu waiting for the player to press Start. With `-statefile <path>` PCSX2 loads the slot-1 `.p2s` file before rendering frame 1, so the cabinet drops the player into the gameplay screen they'll actually play from.

---

## All the configuration (cabinet-tested 2026-05-24)

### 1. `batocera.conf` — nine system-wide keys

Append to `/userdata/system/batocera.conf` (or set via `batocera-settings-set`):

```ini
# PS2 vertical CRT (cabinet-tested 2026-05-24 on v43 + CRT Script)
ps2.emulator=pcsx2
ps2.autosave=0
ps2.incrementalsavestates=0
ps2.pcsx2_bilinear_filtering=0
ps2.pcsx2_blur=true
ps2.pcsx2_gfxbackend=14
ps2.pcsx2_vsync=1
ps2.pcsx2_resolution=1
ps2.pcsx2_texture_filtering=2
```

Set via:

```bash
batocera-settings-set ps2.emulator                  pcsx2
batocera-settings-set ps2.autosave                  0
batocera-settings-set ps2.incrementalsavestates     0
batocera-settings-set ps2.pcsx2_bilinear_filtering  0
batocera-settings-set ps2.pcsx2_blur                true
batocera-settings-set ps2.pcsx2_gfxbackend          14
batocera-settings-set ps2.pcsx2_vsync               1
batocera-settings-set ps2.pcsx2_resolution          1
batocera-settings-set ps2.pcsx2_texture_filtering   2
```

What each key does:

| Key | PCSX2.ini target | Effect |
|-----|------------------|--------|
| `ps2.emulator=pcsx2` | (configgen branch) | Force standalone PCSX2-Qt. Do **not** set `ps2.core=pcsx2` — that selects libretro pcsx2 which is broken on v43 BC250 (AVX-512 SIGILL). |
| `ps2.autosave=0` | `EmuCore.SaveStateOnShutdown = false` | **Disables save-state-on-exit.** Critical: prevents PCSX2 from creating a `<rom>.p2s.auto` file on quit that would later auto-load instead of the operator's bootstrap. |
| `ps2.incrementalsavestates=0` | `EmuCore.AutoIncrementSlot = false` | F1 always saves to the currently active slot (slot 1 in this recipe), not auto-incremented to slot 2/3/etc. Keeps the bootstrap workflow simple. |
| `ps2.pcsx2_bilinear_filtering=0` | `EmuCore/GS.linear_present_mode = 0` | Nearest neighbor on the final present-to-screen step. Without this the rotated framebuffer is bilinear-stretched into the portrait CRT surface, producing visible blur. **This key was discovered to be exposed in the EmulationStation per-system menu** (Per System Settings → PlayStation 2 → Bilinear Filtering → Off). |
| `ps2.pcsx2_blur=true` | `EmuCore/GS.pcrtc_antiblur = true` | Enables PCSX2's PCRTC anti-blur (counterintuitively, `blur=true` here means "anti-blur is ON" → sharper output). |
| `ps2.pcsx2_gfxbackend=14` | `EmuCore/GS.Renderer = 14` | **Vulkan renderer.** Software (`=13`) was tested for shmups and produced no sharpness gain on this hardware; Vulkan is faster on BC250 and visually equivalent. |
| `ps2.pcsx2_vsync=1` | `EmuCore/GS.VsyncEnable = 1` | VSync on. Eliminates tearing on the CRT. |
| `ps2.pcsx2_resolution=1` | `EmuCore/GS.upscale_multiplier = 1` | **1x PS2 native (~512×448).** Higher values (2x/3x) cause sprite-rendering artifacts on Cave 2D shmups even when texture filtering is set to Nearest. Native is the only value that's universally safe on shmup ports. |
| `ps2.pcsx2_texture_filtering=2` | `EmuCore/GS.filter = 2` | PS2-spec texture bilinear (game requests bilinear → applied; game requests nearest → applied). Setting `=0` (force nearest) makes fonts look chunky on every PS2 menu; PS2-spec is the correct default. |

The 9-key system-wide block applies to every PS2 game launched on this cabinet. None of the per-game knobs (resolution, renderer, etc.) need tuning on a per-title basis with this recipe.

### 2. The `pcsx2_fastboot` configgen bug (cosmetic, leave alone)

`ps2.pcsx2_fastboot=true` SHOULD set `EmuCore.EnableFastBoot = true` in PCSX2.ini, which would skip the PS2 BIOS animation. However the v43 `pcsx2Generator.py` has **`return_values=("false", "true")`** on line 273 which inverts the boolean — setting `pcsx2_fastboot=true` actually writes `EnableFastBoot = false`. The bug is upstream and cosmetic for this recipe: when `state_filename` triggers `-statefile` on launch, PCSX2 loads the savestate before rendering frame 1 and the BIOS animation never displays anyway. **Do NOT bother working around the bug.** Set `ps2.pcsx2_fastboot=true` for forward compatibility (in case it gets fixed upstream) and move on.

### 3. Per-game configuration — bootstrap save state + auto-load (operator action per title)

For each PS2 vertical game intended to auto-launch in TATE, three artifacts are required:

1. **In-game TATE persisted to memory card** (the game's own Options menu writes to `/userdata/saves/ps2/pcsx2/Mcd001.ps2`).
2. **One manually-created PCSX2 save state at slot 1** (operator presses F1 mid-gameplay → produces `/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s` + `.png` thumbnail).
3. **Two `batocera.conf` keys + chmod 444 lock** on the save state file.

#### 3a. First-launch ritual (per title)

1. Launch the game from EmulationStation. BIOS plays normally on this first launch (no `state_filename` set yet).
2. **Handle memory card creation prompt.** Many Japanese PS2 games show a Japanese-language prompt at boot asking to create save data on Memory Card slot 1. Pick **YES** at every prompt to allow the game to allocate its memory card slot.
   - Some titles show a second prompt ("Start game without saving?" — `このままゲームを開始しますか？`) — pick **YES** there too.
   - Triggerheart Exelica Enhanced (SLPM-55052) loops at these prompts on the European SCPH30004R BIOS regardless of YES/NO answers — see [Hard locks](#hard-locks-for-this-approach-to-work) below; **drop the PS2 version**, use the Dreamcast or NAOMI port instead.
3. Reach the game's Options / Config menu, set **Screen** / **Orientation** / **Tate Mode** to **ON** (label varies per title). Save to memory card from the game's own menu.
4. **Exit cleanly** (`HOTKEY + START` or Esc → Exit). This writes the memory card to disk.
5. **Relaunch.** Game should boot in TATE this time (memory card persists). If not, repeat the in-game TATE step — the save didn't take.
6. Play past every intro, splash, attract loop, default menu choice — get to the exact moment you want every future launch to start at (e.g. just the player-1 ready prompt).
7. **Press F1.** PCSX2 saves slot 1 → produces `/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s` + `.png`.
8. Exit the game.

#### 3b. Verify the bootstrap save landed

```bash
ROM="Shikigami no Shiro II.chd"  # exact filename including extension
ls -la "/userdata/saves/ps2/pcsx2/sstates/${ROM}.01.p2s"
```

Expect a ~10–15 MB file with mtime matching the F1 press.

#### 3c. Wire up auto-load via `batocera.conf` and lock the file

```bash
ROM="Shikigami no Shiro II.chd"
SS="/userdata/saves/ps2/pcsx2/sstates/${ROM}.01.p2s"

batocera-settings-set "ps2[\"${ROM}\"].state_filename" "$SS"
batocera-settings-set "ps2[\"${ROM}\"].state_slot"     1

chmod 444 "$SS"
chmod 444 "${SS}.png"
```

Result on next launch: configgen reads the per-game keys → appends `-statefile <SS> -stateindex 1` to the pcsx2-qt command → PCSX2-Qt loads the slot-1 save before rendering frame 1 → cabinet boots directly into gameplay in TATE. The `chmod 444` makes accidental F1 mid-game *silently fail* instead of overwriting the bootstrap (PCSX2 attempts the write, hits EACCES, no in-game error message but the file is preserved).

Key meanings:

| Key | Effect |
|-----|--------|
| `ps2["<ROM>"].state_filename=<full path>` | Configgen reads this and appends `-statefile <path>` to the pcsx2-qt command line. PCSX2-Qt auto-loads the specified save state file on boot. **This is the only key that triggers auto-load** — `state_slot` alone does NOT. |
| `ps2["<ROM>"].state_slot=1` | Configgen appends `-stateindex 1` to pcsx2-qt. Sets the active slot context for in-game F1 (save to slot 1) and F3 (load from slot 1) hotkeys. Without this, hotkeys would default to slot 0. |
| `chmod 444 <save state>` | Read-only file permission. PCSX2's F1 save handler attempts write → fails with EACCES → bootstrap file is preserved. |

#### 3d. Updating the bootstrap deliberately

If you ever want to update the bootstrap (e.g. you got better at the game and want to skip a tutorial):

```bash
SS="/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s"
chmod 644 "$SS" "${SS}.png"
# launch game, play to new spot, F1, exit
chmod 444 "$SS" "${SS}.png"
```

### 4. Helper script for batch wiring

A small shell script can auto-detect new unlocked slot-01 save states and wire them all at once. Useful when wiring many titles in a batch session:

```bash
#!/bin/sh
# /tmp/wire-ps2-bootstraps.sh
set -e
SSDIR=/userdata/saves/ps2/pcsx2/sstates

for STATE in "$SSDIR"/*.01.p2s; do
  [ -f "$STATE" ] || continue
  BASENAME=$(basename "$STATE")
  ROM="${BASENAME%.01.p2s}"
  PNG="${STATE}.png"

  batocera-settings-set "ps2[\"${ROM}\"].state_filename" "$STATE"
  batocera-settings-set "ps2[\"${ROM}\"].state_slot"     1

  chmod 444 "$STATE"
  [ -f "$PNG" ] && chmod 444 "$PNG"
done
```

Run after each per-title F1 session; idempotent (re-running on already-locked states is a no-op).

---

## Per-title status (cabinet roster, 12 wired 2026-05-24)

| Title | ROM file | Status (2026-05-24) | Notes |
|-------|----------|---------------------|-------|
| Castle Shikigami II | `Shikigami no Shiro II.chd` | **PASS** | First validated title (recipe origin). Looks sharp at 1x native. |
| DoDonPachi Dai-Ou-Jou | `Dodonpachi Dai-Ou-Jou.chd` | **PASS** | Cave 2007. Small black bars (4:3 framebuffer in portrait window); acceptable per operator. |
| Espgaluda | `Espgaluda (Japan).chd` | **PASS, soft** | Cave 2005 PS2 port is inherently soft at 1x. Tested 2x/3x upscale + software renderer — no improvement. Source port limitation. |
| Gunbird Special Edition | `Gunbird Special Edition.chd` | **PASS** | Psikyo anthology. |
| Homura (Europe) | `Homura (Europe).chd` | **PASS** | Skonec, European release. |
| Ibara | `Ibara.chd` | **PASS** | Cave 2005. |
| Mushihime-sama | `Mushihime-sama (Japan).chd` | **PASS** | Cave 2004. |
| Psyvariar 2 - Ultimate Final | `Psyvariar 2 - Ultimate Final.chd` | **PASS** | Success Corp. |
| Raiden III | `Raiden III (Europe).chd` | **PASS** | Moss, European release. |
| Castle Shikigami | `Shikigami no Shiro.chd` | **PASS** | Original (predecessor to II). |
| Shooting Love - Trizeal | `Shooting Love - Trizeal (Japan).chd` | **PASS** | Triangle Service, PS2 port of DC release. |
| XII Stag | `XII Stag.chd` | **PASS** | Triangle Service. |
| ~~Triggerheart Exelica Enhanced~~ | ~~`Triggerheart Exelica enhanced.chd`~~ | **SKIPPED — use DC version** | SLPM-55052 (Japan). Loops at BIOS memory-card-create prompts on European SCPH30004R BIOS. PS2 "Enhanced" extras (arrange music, extra modes) judged not worth fighting region check. **Dreamcast version `Triggerheart Exelica (Japan).cdi` available; use Flycast TATE workflow instead.** |

Per-title test procedure for additional titles:

1. Drop the disc image into `/userdata/roms/ps2/`.
2. First launch → handle memory card prompts (YES, YES if asked twice) → enter in-game Options → set TATE → save to memory card → exit cleanly.
3. Relaunch → confirm TATE persists from memory card. If not, repeat step 2 (in-game save didn't take).
4. Play to the desired launch spot.
5. **F1** → bootstrap save state created.
6. Run the batch wire script (or manually run the three `batocera-settings-set` + `chmod 444` commands).
7. Relaunch from EmulationStation → confirm zero-touch boot into TATE gameplay.

---

## Adding a new PS2 title later

Identical to the per-title test procedure above. The recipe is fully per-game; the system-wide keys never change once initially set.

---

## Save / state directory layout

After PS2 titles are launched on this cabinet:

| File | Purpose |
|------|---------|
| `/userdata/saves/ps2/pcsx2/Mcd001.ps2` | **PS2 memory card slot 1.** 8 MB binary blob holding every game's persistent settings (including TATE mode). Written by PCSX2 during gameplay when the game writes to its save data. |
| `/userdata/saves/ps2/pcsx2/Mcd002.ps2` | Memory card slot 2 (rarely used by shmups). |
| `/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s` | **Bootstrap save state slot 1.** Operator-created via F1. Auto-loaded on launch when `state_filename` per-game key is set. Locked with `chmod 444` to prevent accidental overwrite. |
| `/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s.png` | Thumbnail of the save state (PCSX2 generates automatically when F1 is pressed). Locked alongside the `.p2s`. |
| `/userdata/saves/ps2/pcsx2/sstates/<ROM>.p2s.auto` | Auto-save-on-exit file. **Should NOT exist** with this recipe (`ps2.autosave=0` disables it). If present, delete: the auto-save would interfere with the deterministic bootstrap. |
| `/userdata/system/configs/PCSX2/inis/PCSX2.ini` | PCSX2-Qt main config. Regenerated by configgen on every launch. Operator should not hand-edit — set values via `ps2.*` keys instead. |

---

## Hard locks for this approach to work

- **Emulator: standalone PCSX2 only.** `ps2.emulator=pcsx2` (NOT `ps2.core=pcsx2` which selects libretro pcsx2). The libretro PS2 core in v43 is built with AVX-512 SIMD instructions that crash with SIGILL on the BC250 APU. Standalone PCSX2-Qt v2.5.229 works. Even if a future v43 build ships a non-AVX-512 libretro core, the per-game CLI-args mechanism (`-statefile` / `-stateindex`) is standalone-only — switching to libretro would invalidate every per-game `state_filename` key.
- **PS2 BIOS in `/userdata/bios/ps2/`.** PCSX2 will not boot without a BIOS file. SCPH30004R (European), SCPH70012 (USA), SCPH77000 (Japan) all work. Mixing regions: many Japanese games (Cave, Triangle Service) run fine on European BIOS, but Triggerheart Exelica Enhanced specifically loops at the memory card prompt with European BIOS — if Japanese titles fail similarly, a Japanese BIOS may be needed. **Do not borrow Myzar's v42-era BIOS files — they have caused boot loops on v43.**
- **Bootstrap save state is operator-captured.** There is no general way to synthesize a `<ROM>.01.p2s` file. Each title requires the operator to play through the intros + menus once and press F1 at the launch spot. For redistributable autoconfig, the `.01.p2s` + `.png` pair can be bundled as static assets (one pair per title × ~12 MB = ~150 MB for a 12-title roster).
- **`state_filename` requires the full absolute path.** Relative paths or paths with `~` are not expanded. The value must be exactly `/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s` (with the original ROM extension preserved in the basename).
- **`chmod 444` lock is essential.** Without it, an accidental F1 mid-game silently overwrites the bootstrap with a worse mid-stage state, and the next launch drops into wherever the player happened to be when they fat-fingered F1.
- **`ps2.autosave=0` is essential.** Without it, every clean exit creates a `<ROM>.p2s.auto` file that PCSX2-Qt prefers over the operator's `.01.p2s` bootstrap. The `state_filename` key would be silently overridden.
- **Geometry.** This recipe assumes v43 + CRT Script has already produced correct PS2 video output. The 9 system-wide keys add rendering + state-injection on top of that geometry; they do not set videomode. Switchres runs as normal during PS2 launch (validated 2026-05-24: launch log shows `setMode 641x480.60.00082` for every PS2 game).
- **No per-game render overrides in this recipe.** Castle Shikigami II, DoDonPachi, and Espgaluda all use the same 9 system-wide keys. Tested per-game `pcsx2_ratio=Stretch` and `pcsx2_resolution=2` overrides — Stretch helps DoDonPachi's bars but distorts other titles; 2x produces artifacts. Operator preference is **system-wide settings only**, accept inherent per-game variance in source-port quality.

---

## Risks / gotchas

- **`pcsx2_fastboot=true` is silently broken** (see Section 2). The setting writes `EnableFastBoot=false` due to inverted `return_values` in pcsx2Generator.py line 273. Cosmetic only — `state_filename` makes BIOS animation invisible regardless. Do not invest time in working around.
- **ES per-system PS2 menu can clobber `batocera.conf`.** Toggling Per System Settings → PlayStation 2 in EmulationStation rewrites the `ps2.*` section. Specifically observed: `ps2.pcsx2_fastboot=true` was removed when the operator touched ES per-system PS2 settings. Re-apply the 9-key block via `batocera-settings-set` if any keys go missing.
- **Per-game `pcsx2_blur=false` looks counterintuitive.** ES exposes this as "Anti-blur" or similar — the value semantics are inverted relative to the label. `pcsx2_blur=true` means "anti-blur ON" → sharper output. Operator briefly toggled per-game Espgaluda to `false` thinking it would reduce blur; it actually doubled blur. Removed via `sed`. If a future operator does the same, search for `ps2\[.*\]\.pcsx2_blur=false` lines and delete.
- **Espgaluda is just a soft port.** Cave's PS2 port renders at a low internal framebuffer with heavy use of PS2's spec bilinear. On a real CRT in 2003 the natural scanlines hid the softness. No PCSX2 setting recovers sharpness; tested 2x/3x upscale (artifacts), software renderer (no difference), nearest texture filter (fonts chunky). Accept the source quality.
- **DoDonPachi has visible black bars in portrait mode.** The PS2 port renders a 4:3 landscape framebuffer with the TATE content composed inside it. When the framebuffer is rotated to portrait, the 4:3 content occupies only ~70% of the portrait CRT vertical, leaving ~15% black bar top + ~15% bottom. `pcsx2_ratio=Stretch` per-game would fill the screen but distorts aspect; operator preference is the system-wide `Auto 4:3/3:2` default → accept the bars.
- **Higher internal resolution (`pcsx2_resolution=2` or `3`) causes artifacts on Cave 2D ports.** Tested on Espgaluda and DoDonPachi at both 2x and 3x — sprite-edge artifacts, font shimmer. 1x native is the only universally-safe value across Cave's PS2 catalog. Other (non-Cave) PS2 games might benefit from 2x, but the operator's roster is heavily Cave-leaning and the artifacts on Cave titles outweighed any gain on non-Cave titles.
- **Region-locked Japanese titles may loop at BIOS memory card prompts.** Triggerheart Exelica Enhanced (SLPM-55052) confirmed. The pattern: BIOS shows "No save data on Memory Card. Create?" → YES → second prompt "Start without saving?" → YES → loops back to first prompt indefinitely. Workaround: use a different version of the title (NAOMI / Dreamcast port if available) and drop the PS2 version. If no alternate port exists, a Japanese BIOS (SCPH77000) may resolve — untested on this cabinet.
- **PCSX2-Qt menu nomenclature.** The in-emulator pause menu (ESC) has Reset System under the **Close Game** submenu, not the main pause menu. Reset is safe — it only resets the current game's emulation, NOT memory cards or other games' save states.
- **Cabinet-bound save state paths.** The full `state_filename` path includes `/userdata/saves/ps2/pcsx2/sstates/` which is identical across Batocera installs. The `<ROM>` portion must match the ROM filename **including the extension** (e.g. `.chd`). Renaming a ROM after wiring breaks auto-load — re-wire after any rename.

---

## QA checklist (current as of 2026-05-24)

1. **System-wide keys present:**
   ```bash
   batocera-settings-get ps2.emulator                  # → pcsx2
   batocera-settings-get ps2.autosave                  # → 0
   batocera-settings-get ps2.incrementalsavestates     # → 0
   batocera-settings-get ps2.pcsx2_bilinear_filtering  # → 0
   batocera-settings-get ps2.pcsx2_blur                # → true
   batocera-settings-get ps2.pcsx2_gfxbackend          # → 14
   batocera-settings-get ps2.pcsx2_vsync               # → 1
   batocera-settings-get ps2.pcsx2_resolution          # → 1
   batocera-settings-get ps2.pcsx2_texture_filtering   # → 2
   ```
2. **BIOS present:**
   ```bash
   ls /userdata/bios/ps2/SCPH*.bin
   ```
3. **Per-game bootstrap pair present + locked (per title):**
   ```bash
   ls -la /userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s
   # → -r--r--r-- 1 root root … <date> <ROM>.01.p2s
   ```
4. **Per-game keys present (per title):**
   ```bash
   grep "^ps2\[\"<ROM>\"\]" /userdata/system/batocera.conf
   # → ps2["<ROM>"].state_filename=/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s
   # → ps2["<ROM>"].state_slot=1
   ```
5. **No auto-save artifacts present (per title):**
   ```bash
   ls /userdata/saves/ps2/pcsx2/sstates/<ROM>.p2s.auto 2>/dev/null
   # → (should not exist; delete if present)
   ```
6. **Launch test matrix:**
   - One straightforward title (e.g. **Castle Shikigami II**) → boots into TATE at saved spot, sharp.
   - One Cave shmup (e.g. **DoDonPachi Dai-Ou-Jou**) → boots into TATE at saved spot, visible bars (acceptable).
   - One soft-port title (e.g. **Espgaluda**) → boots into TATE at saved spot, soft (acceptable, source limitation).
   - Quit, relaunch any of the above → mtime on `.01.p2s` unchanged (lock holding), launch identical to first time.

---

## SSH note (`ssh-batocera.sh`)

```bash
~/bin/ssh-batocera.sh 10.23.6.210 'grep ^ps2 /userdata/system/batocera.conf | sort'
~/bin/ssh-batocera.sh 10.23.6.210 'ls -la /userdata/saves/ps2/pcsx2/sstates/'
~/bin/ssh-batocera.sh 10.23.6.210 'ls /userdata/saves/ps2/pcsx2/Mcd*.ps2'
```

When writing the helper script for batch wiring, prefer writing the shell script to a local file and `rsync`-ing it to `/tmp/` on the cabinet, then SSH to `chmod +x && run`. Embedding multi-line bash with quoted ROM names directly inside an SSH command string is fragile (nested expect quoting eats the inner `"` around ROM basenames).

---

## Links

- Generator merge spec: [ps2-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/ps2-vertical-autoconfig.md)
- Saturn / Dreamcast (state-injection precedent, but on libretro with `.state.auto` files): [saturn-vertical-vanilla-v43.md](saturn-vertical-vanilla-v43.md), [dreamcast-vertical-vanilla-v43.md](dreamcast-vertical-vanilla-v43.md)
- PSX (different core; in-game TATE via memory card without state-injection): [psx-vertical-vanilla-v43.md](psx-vertical-vanilla-v43.md)
- NAOMI: [naomi-vertical-vanilla-v43.md](naomi-vertical-vanilla-v43.md)
- Sibling vertical specs: [pcengine-vertical-vanilla-v43.md](pcengine-vertical-vanilla-v43.md), [snes-vertical-vanilla-v43.md](snes-vertical-vanilla-v43.md), [vectrex-vertical-vanilla-v43.md](vectrex-vertical-vanilla-v43.md)
- PCSX2 configgen source: `/usr/lib/python3.12/site-packages/configgen/generators/pcsx2/pcsx2Generator.py` (lines 135–140 for `-statefile`/`-stateindex`, line 273 for the inverted `EnableFastBoot` bug)
