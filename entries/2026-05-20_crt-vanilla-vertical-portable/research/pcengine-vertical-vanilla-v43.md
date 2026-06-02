# PC Engine / PC Engine CD - vertical cabinet on vanilla Batocera v43

**Sessions:** [Vanilla vertical portable](../plan.md) (target) · [Myzar DP hybrid](../../2026-05-21_crt-myzar-dp-hybrid-switchres/research/emulator-expected-resolutions.md) (reference only)  
**Roster source:** Mac volume `Batocera/vertical/roms/` (2026-05-21 listing)  
**Default emulator (Batocera):** `libretro` + core **`pce_fast`** (Beetle PCE Fast), see `batocera.linux` `configgen-defaults.yml`  
**Related:** [SNES vertical](snes-vertical-vanilla-v43.md), [Vectrex vertical](vectrex-vertical-vanilla-v43.md), [Saturn vertical](saturn-vertical-vanilla-v43.md), [Dreamcast vertical](dreamcast-vertical-vanilla-v43.md), [NAOMI vertical](naomi-vertical-vanilla-v43.md), [PSX vertical](psx-vertical-vanilla-v43.md); autoconfig spec [pcengine-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/pcengine-vertical-autoconfig.md).

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
3. Copied PC Engine HuCARD ROMs to `/userdata/roms/pcengine/` and PCE-CD images to `/userdata/roms/pcenginecd/`.
4. Dropped any required PCE-CD BIOS (e.g. `syscard3.pce`) into `/userdata/bios/`.

Everything below adds PC Engine + PCE CD vertical-shmup support on top of that baseline. It does not change any other system, the CRT display profile, or the global rotation; it only touches **two** `pcengine.*` keys and **two** `pcenginecd.*` keys (plus optional per-game RetroArch tweaks).

---

## Deployed policy (2026-05-21)

**Cabinet:** `batocera.local` (vanilla Batocera + CRT stack in use during this session).

**Decision:** Use one **global** 15 kHz timing for **all** HuCARD and **all** CD titles, instead of per-ROM `videomode` lines.

**File:** `/userdata/system/batocera.conf` (append block; do not duplicate per game unless you need an exception).

```ini
# PC Engine / PC Engine CD default CRT timing (256x224)
pcengine.videomode=256x224.60.00004
pcenginecd.videomode=256x224.60.00004
pcengine.ratio=core
pcenginecd.ratio=core
```

**Mode string:** `256x224.60.00004` was chosen from **`batocera-resolution listModes`** on that device (same precision style as `global.videomode`). If you reflash or regenerate `videomodes.conf`, re-check `listModes` and adjust the suffix if the catalog changes.

**Cross-system (SNES, same cabinet):** PCE uses **`ratio=core`** at **256×224**; SNES on this stack needed a **taller `videomode`** and **`ratio=full`** for a clean fill. Do not copy PCE’s mode onto SNES. See [SNES vertical portable](snes-vertical-vanilla-v43.md).

**RetroArch (optional):** per-title tweaks live under  
`/userdata/system/configs/retroarch/config/Beetle PCE Fast/`  
(e.g. `Blazing Lazers.cfg` with `aspect_ratio_index` + `video_scale_integer`). These apply **only** when that game loads and do **not** replace the global `videomode` above.

**Removed during migration:** per-ROM `pcengine["Some Game.zip"].videomode=` / `.ratio=` entries for Blazing Lazers and Dragon Saber so they do not override the globals.

## Myzar vs vanilla (do not copy blindly)

| Myzar hybrid stack | Vanilla v43 + CRT Script |
|--------------------|---------------------------|
| `zzz-myzar-switchres.sh`, `batocera-resolution` → myzar symlink, `batocera-get-game-mode.sh` | Stock Batocera resolution + **CRT Script** outputs (`videomodes.conf`, `first_script.sh`, etc.) |
| `super_width=1024`, wide X timings (e.g. 512×240 → **2048×240**) | Super-res width follows **your** installer / GPU profile, not Myzar’s fixed 1024 |
| Per-output `xrandr` tricks (e.g. FBNeo Sai only) | **Do not** paste Sai-only rotation flags unless the same bug appears on vanilla |

**Portable from Myzar docs:** PCE is a good system to test **after** SNES on CRT. Myzar notes suggested **`512x240`** class timings in some stacks; on **this** vanilla cabinet, **`512x240`** did **not** appear in `listModes`, while **`256x224.60.00004`** and several **`512x224.*`** entries **did**. The **global default** uses **256×224** for simplicity; optional in-game **512-wide** modes still need a **per-ROM** `videomode` override if you want the X mode to match the core exactly when that mode is active. **Automation follow-on:** see companion KB session `2026-05-22_crt-vertical-autoconfig-script` for a planned CRT Script merge tool (spec in that session’s `research/`).

## Roster (from `vertical/roms/`)

### PC Engine (16 zips)

| ROM | Notes for vertical CRT |
|-----|-------------------------|
| Blazing Lazers.zip | Vertical shmup |
| Dragon Saber.zip | Vertical |
| Dragon Spirit.zip | Vertical |
| Final Blaster.zip | Vertical |
| Galaga '90.zip | Vertical |
| Hanii in the Sky.zip | Vertical (scraped genre) |
| Psycho Chaser.zip | Vertical (description) |
| Soldier Blade.zip | Vertical; **Arcade / hi-res** from **Options** per [tg-16.com](https://www.tg-16.com/arcade-mode-high-resolution-shmups.htm) |
| Somer Assault.zip | Top-down maze; may want **per-game** aspect / rotation tweak |
| Space Harrier.zip | **Horizontal** pseudo-3D; expect different treatment than the rest |
| Space Invaders - Fukkatsu no Hi.zip | Vertical |
| Super Star Soldier.zip | Vertical; hi-res unlock is a **code sequence** (same source) |
| Tatsujin.zip | Vertical; **Slim** via debug path (same source) |
| Terra Cresta II - Mandoraa no Gyakushuu (Japan).zip | Vertical |
| Toilet Kids.zip | Vertical |
| Toy Shop Boys.zip | Vertical |

### PC Engine CD (19 `.chd`)

Vertical-leaning shmups / STG-heavy set (Nexzr, Image Fight II, Spriggan, Summer Carnival titles, Sylphia, Super Raiden, etc.). **Sapphire** and some others are **horizontal**; tune per title like Space Harrier if needed.

## How Batocera applies “vertical” without Myzar

For systems where the display stack does **not** own rotation, Batocera’s libretro generator injects **`video_rotation`** from **`display.rotate`** (see `libretroConfig.py` on batocera.linux). With **`display.rotate=1`**, that is the same global rotation class used for other libretro systems on a TATE cabinet.

**Beetle PCE Fast** does not expose a Batocera-specific “TATE mode” in `libretroOptions.py` beyond `pce_nospritelimit`. Most PCE vertical games still use a **horizontal framebuffer** (scroll direction is vertical); they usually **share one global rotation** with the rest of the vertical build. Titles that are **actually horizontal** (Space Harrier, some CD games) are the ones that need **per-game** `video_rotation` overrides or `aspect_ratio` / `custom_viewport` fixes.

## Bring-up checklist (vanilla)

1. **CRT Script installer** finished; **`display.rotate`** matches your panel (see `plan.md` / `crt-installer-choices.md` when filled in).
2. **Confirm mode exists** on the target device:

   ```bash
   export DISPLAY=:0
   batocera-resolution listModes | grep -E '256x224|512x224'
   ```

3. **Set globals** as in [Deployed policy](#deployed-policy-2026-05-21) (adjust the mode string to match `listModes` output).
4. **Core:** keep **`pce_fast`** unless a title misbehaves; **`pce`** (Beetle PCE accurate) is the alternative in ES for edge cases.
5. **Per-game RetroArch overrides** only when needed:  
   `/userdata/system/configs/retroarch/config/Beetle PCE Fast/`  
   Typical tweaks: `video_rotation`, `aspect_ratio_index`, `video_scale_integer`, `custom_viewport_*`. Filenames follow RetroArch / playlist naming (confirm with `ls` after one **Save Game Overrides** from the quick menu).
6. **QA order:** one HuCARD (e.g. Blazing Lazers) + one CD (e.g. Nexzr), then **Space Harrier** if you need the horizontal-exception path.

## Links

- Myzar timing table (reference): [emulator-expected-resolutions.md](../../2026-05-21_crt-myzar-dp-hybrid-switchres/research/emulator-expected-resolutions.md)
- Portable policy (why not Myzar): [plan.md](../plan.md)
- PCE shmups with optional high-resolution “Arcade mode” (unlock varies by title): [tg-16.com](https://www.tg-16.com/arcade-mode-high-resolution-shmups.htm)
