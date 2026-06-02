# Nintendo Switch (Citron) — vertical cabinet on vanilla Batocera v43

**Session:** [Vanilla vertical portable](../plan.md)
**Default emulator (v43 cabinet, locked here):** **`citron-emu`** via the **unofficial Switch add-on** (`/userdata/system/switch/appimages/citron-emu.AppImage`, launched by `edenGenerator.py`). **NOT** stock Batocera `switch.emulator=citron` (points at missing `/usr/bin/citron`).
**Related:** [PSX vertical](psx-vertical-vanilla-v43.md) (closest sibling: in-game TATE persisted outside the emulator config layer), [PS2 vertical](ps2-vertical-vanilla-v43.md) (another standalone emulator, but PS2 uses bootstrap save states), autoconfig spec [switch-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/switch-vertical-autoconfig.md).

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
3. Installed the **unofficial Switch add-on** (provides `citron-emu.AppImage`, `edenGenerator.py`, and related tooling under `/userdata/system/switch/`).
4. Copied Switch **keys + firmware** to `/userdata/bios/switch/keys/` and `/userdata/bios/switch/firmware/` (mandatory for Citron).
5. Copied the three Cave shmup ROMs to `/userdata/roms/switch/` (`.nsp` / `.xci`).

Everything below adds Switch vertical-shmup support on top of that baseline. It does not change any other system, the CRT display profile, or the global rotation.

---

## Why Switch is a new recipe class (seventh)

Switch does not fit the six prior libretro / PCSX2 classes:

| Class | Examples | Mechanism |
|-------|----------|-----------|
| Geometry | PCE / SNES / Vectrex | system-wide videomode + ratio |
| State-injection (libretro) | Saturn / Dreamcast / PSP | `.state.auto` + RA autoload keys |
| Rotation-only | NAOMI | one RA rotation key |
| Rotation + fill + per-game viewport | PSX | 3 system-wide keys + per-game RA cfg |
| Standalone bootstrap-state | PS2 | PCSX2-Qt keys + locked `.p2s` bootstrap |
| State-injection + two-tier + remap | PSP | RA rotation tiers + D-pad remap |
| **Standalone Citron + in-game TATE save** | **Switch** | **7 `switch.*` keys + operator in-game TATE menu (persists to Citron save data)** |

Switch specifics:

| Concern | Switch | PSX (Cave family) | PS2 |
|---------|--------|-------------------|-----|
| Emulator | **Citron AppImage** (`citron-emu`) | libretro `pcsx_rearmed` | standalone PCSX2-Qt |
| Per-game batocera keys | **none** on this 3-title roster | custom viewport cfg for 2 titles | `state_filename` + `state_slot` per title |
| In-game TATE storage | **Citron virtual SD save data** (`/userdata/system/configs/yuzu/sdmc/…`) | PSX memory card (`.1.mcr`) | PS2 memory card + optional bootstrap `.p2s` |
| Skip-menu autoload | **none** (launch through game menus once) | n/a | `-statefile` bootstrap |
| RetroArch | **not used** | used | not used |

The operator enables TATE once per title in the game's Options menu; Citron persists that setting to save data on clean exit. No state-injection, no RA rotation, no input remap layer.

---

## Cabinet roster (3 titles, all PASS 2026-05-24)

| Title | ROM file | Title ID |
|-------|----------|----------|
| DoDonPachi Resurrection | `DoDonPachi Resurrection.nsp` | `01005A001489A000` |
| Espgaluda 2 | `Espgaluda 2 -Be Ascension The Third Bright Stone of Birth.xci` | `0100911014898000` |
| Mushihimesama | `Mushihimesama.nsp` | `010045800FBD0000` |

---

## All the configuration (cabinet-tested 2026-05-24)

### 1. `batocera.conf` — seven system-wide keys

```ini
# Switch vertical CRT (cabinet-tested 2026-05-24 on v43 + CRT Script + unofficial Switch add-on)
switch.emulator=citron-emu
switch.core=citron-emu
switch.videomode=864x486.60.00070
switch.yuzu_backend=1
switch.yuzu_ratio=5
switch.language=1
switch.citron_resolution_scale=2
```

Set via:

```bash
batocera-settings-set switch.emulator              citron-emu
batocera-settings-set switch.core                  citron-emu
batocera-settings-set switch.videomode             864x486.60.00070
batocera-settings-set switch.yuzu_backend          1
batocera-settings-set switch.yuzu_ratio            5
batocera-settings-set switch.language              1
batocera-settings-set switch.citron_resolution_scale 2
```

| Key | Effect |
|-----|--------|
| `switch.emulator=citron-emu` + `switch.core=citron-emu` | Lock unofficial Citron AppImage path. **Do not** use stock `citron` (missing binary on v43). |
| `switch.videomode=864x486.60.00070` | 15 kHz widescreen timing from the CRT Script catalog (Myzar reference used the short token `864x486.60.00`; v43 active catalog uses `.00070` suffix). |
| `switch.yuzu_backend=1` | Vulkan renderer (written to `yuzu/qt-config.ini` `Renderer/backend` by `edenGenerator.py`). |
| `switch.yuzu_ratio=5` | **Stretch to window** in Citron (`Renderer/aspect_ratio=5`). Fills the rotated CRT surface when the game is in portrait TATE mode. |
| `switch.language=1` | English UI in emulated Switch system settings. |
| `switch.citron_resolution_scale=2` | 1× internal resolution (720p/1080p docked). Higher scales can artifact on 2D Cave ports. |

Optional: `switch.bezel=none` (already set on reference cab).

**No per-game `switch["…"].*` keys** are required for these three titles.

### 2. Citron config (materialized by configgen)

Path: `/userdata/system/configs/yuzu/qt-config.ini` (symlinked into `citron/` by the add-on).

The add-on's `edenGenerator.py` regenerates relevant sections on every launch from the `switch.*` keys above. Do not hand-edit expecting persistence across launches unless the key is not mapped by configgen.

Key persisted values after deploy:

- `Renderer/aspect_ratio=5` (stretch)
- `Renderer/backend=1` (Vulkan)
- `Renderer/resolution_setup=2` (1×)
- `System/use_docked_mode=true` (default)
- `UI/fullscreen=true`

### 3. Operator one-time TATE ritual (per title)

After the system keys are in place, launch each title once and set in-game TATE (Cave ports; same menu path across the roster):

1. **Options → General Screen → Rotate → Right Roll**
2. **Link Rotation → ON**
3. Play briefly, then **exit cleanly** (hotkey + Start kills Citron; ensure the game had a chance to flush save data).

Citron stores the setting under the virtual SD tree (`/userdata/system/configs/yuzu/sdmc/…`). After the first successful save, subsequent launches should open directly in TATE.

Reference: [Does It Flip — Mushihimesama](https://www.doesitflip.com/games/mushihimesama/) documents the same menu path for the Switch port.

---

## Myzar reference (`10.23.6.214`, v41ocp)

Use Myzar only as a **keys/firmware** reference, not for geometry:

| Item | Myzar | v43 (this recipe) |
|------|-------|-------------------|
| Emulator | `switch.emulator=citron` + `citron.AppImage` | `switch.emulator=citron-emu` + `citron-emu.AppImage` |
| Configgen | Custom `citronGenerator.py` (reads `suyu_ratio`, not `yuzu_ratio`) | `edenGenerator.py` (reads `yuzu_ratio` correctly) |
| `switch.yuzu_ratio=4` on Myzar | Likely **stale** (Force 32:9 in qt-config; generator default is stretch `=5`) | **`switch.yuzu_ratio=5`** (stretch, cabinet-validated) |
| Videomode token | `864x486.60.00` | `864x486.60.00070` |
| CRT Script | Not installed | Installed |
| Save data | Empty sdmc at investigation time | Operator creates on first TATE + clean exit |

Myzar had **no** `.state.auto`, no per-game batocera keys, and no RetroArch layer for Switch.

---

## Hard locks

- **Emulator: `citron-emu` only** (unofficial add-on). Stock `citron` and Eden/Ryujinx placeholders in `/userdata/roms/switch/` are for the add-on's config stubs, not this recipe.
- **Keys + firmware** in `/userdata/bios/switch/` — without them Citron will not boot titles.
- **In-game TATE** is mandatory for vertical play; system keys alone present a horizontal Cave port in a rotated X11 window.
- **Do not borrow** Myzar's geometry / Switchres tricks; this cabinet uses CRT Script + `display.rotate=1`.

---

## Risks and gotchas

- **Stock Batocera default is wrong:** `configgen-defaults.yml` sets `switch.emulator=citron` → broken on v43 without the add-on's AppImage wiring.
- **`yuzu_ratio` semantics:** In the unofficial add-on, `5` = stretch to window, `4` = force 32:9. Myzar's `yuzu_ratio=4` did not reliably apply on v41 (generator checked `suyu_ratio` instead).
- **No skip-menu shortcut:** Unlike Saturn/PSP/PS2, there is no autoload path; first launch goes through Citron + game menus until TATE is saved.
- **Cross-emulator save data:** Save data under `yuzu/sdmc` is tied to Citron/Eden family emulators; switching to Ryujinx for the same title requires separate setup.
- **Resolution scale:** Leaving `citron_resolution_scale` unset on a fresh install may default to 1.5× experimental; this recipe locks `=2` (1×).

---

## QA checklist (cabinet)

- [ ] `switch.emulator=citron-emu` and `switch.core=citron-emu` in `batocera.conf`
- [ ] All seven `switch.*` keys present
- [ ] `/userdata/bios/switch/keys/prod.keys` exists
- [ ] Each of the three ROMs launches without Citron key/firmware errors
- [ ] After in-game TATE ritual: picture fills portrait CRT, controls match TATE orientation
- [ ] Second launch: TATE persists without re-entering Options menu
- [ ] Exit returns ES at correct rotated menu resolution

**Cabinet result (2026-05-24):** all three titles PASS after deploy + operator TATE setup. User confirmed picture "looks great."

---

## Sources

- Myzar investigation (`10.23.6.214`): system keys, AppImage layout, empty save data, custom configgen quirk
- v43 deploy + cabinet test (`10.23.6.210`): 2026-05-24
- Unofficial add-on: `/userdata/system/switch/configgen/generators/edenGenerator.py`
- Cave Switch TATE menu: [Does It Flip — Mushihimesama](https://www.doesitflip.com/games/mushihimesama/)
