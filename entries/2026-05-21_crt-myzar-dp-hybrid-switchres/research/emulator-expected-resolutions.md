# Emulator expected resolutions — Myzar cabinet

**Device:** `batocera.local`, hybrid myzar-dp stack, `display.rotate=1`, `super_width=1024`.  
**Captured:** 2026-05-21 from ROM inventory + `batocera.conf` + `batocera-get-game-mode.sh` probes.

## How timing is applied

1. `zzz-myzar-switchres.sh` `gameStart` calls `batocera-get-game-mode.sh`.
2. Non-empty mode → `batocera-resolution setMode` → Switchres super-res on **DisplayPort-0**.
3. Lookup order: per-game `system["ROM"].videomode` → `system.videomode` → `global.videomode` → MAME `-listxml` **only** if emulator is `mame` or `libretro`.
4. Only **`mame.switchres=1`** in `batocera.conf`; other systems need `*.videomode=` (or MAME core path) to get Switchres.
5. Empty mode → script exits; display often stays **640×480i** (menu timing).

**Menu (all systems):** `640×480i` @ 60 → X **480×640** (rotate right).

**Super-res rule (`super_width=1024`):** Switchres input resolution is stretched ~4× horizontal on X, e.g. `256×224` → **1024×224**, `320×240` → **1280×240**, `384×224` → **1536×224**. `640×480` inputs often stay **640×480**.

---

## Systems with ROMs (excluding empty folders)

| Folder | ROM count | MAME tested |
|--------|-----------|-------------|
| mame | 1072 | Yes (primary) |
| windows | 49 | Pending |
| saturn | 35 | Pending |
| vectrex | 28 | Pending |
| naomi | 23 | Pending |
| pcenginecd | 19 | Pending |
| snes | 20 | Pending |
| pcengine | 16 | Pending |
| fbneo | 14 | Pending |
| ps2 | 13 | Pending |
| dreamcast | 11 | Pending |
| psx | 31 | Pending |
| psp | 4 | Pending |
| atomiswave | 1 | Pending |
| nes | 1 | Pending |
| neogeo | 1 (BIOS only: `neogeo.zip`) | N/A until games added |

---

## MAME (per-game via `-listxml`)

| Game family | Examples | Switchres input | Typical X super-res |
|-------------|----------|-----------------|---------------------|
| Cave 384×224 | ddpdoj, ddp3 | `384x224.59.19` | **1536×224** |
| 320×240 vertical | dfkbl, Mushisam class | `320x240.60.00` | **1280×240** |
| 288×224 | pacman | `288x224.60.61` | **~1152×224** |
| 256×224 | 1942 | `256x224.60.00` | **1024×224** |

`mame.videomode=default` — no fixed global arcade mode.

---

## Will get Switchres today (configured in `batocera.conf`)

| System | ROMs | Expected input timing | Expected X mode (approx.) | Config key |
|--------|------|----------------------|---------------------------|------------|
| **SNES** | 20 | 256×224 @ 60 | **1024×224** | `snes.videomode=256x224.60.00` |
| **PC Engine** | 16 | 512×240 @ 60 | **2048×240** or **1280×240** | `pcengine.videomode=512x240.60.00` |
| **PC Engine CD** | 19 | 512×240 @ 60 | same as PCE | `pcenginecd.videomode=512x240.60.00` |
| **PS2** | 13 | 640×480 @ 60 | **640×480** | `ps2.videomode=640x480.60.00` |
| **PSP** | 4 | 960×480 @ 60 | **960×480** | `psp.videomode=960x480.60.00` |
| **Dreamcast** | 11 | Per game | varies | Only **Gigawing** set: `dreamcast["Gigawing.cdi"].videomode=640x480.60.00` → **640×480** |

---

## Likely 640×480 until `system.videomode` is set

| System | ROMs | Current `get-game-mode` | Suggested timing to add | Expected X super-res |
|--------|------|-------------------------|-------------------------|----------------------|
| **FBNeo** | 14 | `ddpsdoj` hardcoded + per-ROM cfg | **Sai** `ddpsdoj` only — see known-good docs | **PASS** `1280×240` + Sai-only `xrandr right` (MAME same timing uses **normal**) |
| **Naomi** | 23 | empty | `naomi.videomode=640x480.60.00` (VGA); some titles 640×240 | **640×480** |
| **Saturn** | 35 | `saturn.videomode=320x240.60.00`, Beetle core CRT | **1280×240** default; `640×480` per-ROM override | **PASS** — `debug/saturn-beetle-core-crt.md` |
| **PSX** | 31 | empty (no `psx.videomode`) | `320x240.60.00` or `640x480.60.00` | **1280×240** or **640×480** |
| **NES** | 1 | empty | `nes.videomode=256x240.60.00` | **1024×240** |
| **Neo Geo** | 1 | N/A (BIOS only) | Add ROMs; typical `320x240.60.00` | **1280×240** |
| **Atomiswave** | 1 | empty | `640x480.60.00` | **640×480** |
| **Vectrex** | 28 | broken parse (`x.60.00`) | **Vanilla (DP CRT):** use full `listModes` token (e.g. `384x480.60.00028`); merge keys in [vectrex-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/vectrex-vertical-vanilla-v43.md), generator spec [vectrex-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/vectrex-vertical-autoconfig.md) | TBD on this Myzar stack |

---

## Windows (49 games) — per-title `videomode` already in `batocera.conf`

| Expected input | Example titles on cabinet |
|----------------|---------------------------|
| **320×240 @ 60** | Donkey Me, Nyxx, Space Moth DX, Zenodyne R, Bullet Garden, Annalynn, Zenohell, … |
| **426×240 @ 60** | 99Vidas, A Hole New World, … |
| **512×480 @ 60** | 80s OVERDRIVE |
| **640×480 @ 60** | Raiden III/IV, Wolflame, Homura, Crisis Wing, Gunvein, Moon Dancer, … |
| **720×480 @ 60** | Dead End City |
| **854×480 @ 60** | HellBlasters |
| **864×486 @ 60** | GhostBlade HD, Sophstar |
| **1280×480 @ 60** | Cho Ren Sha 68k, Crimzon Clover World Ignition |

Super-res: `320×240` → **1280×240**; many **640×480** entries stay **640×480** on X.

---

## Suggested CRT test order

1. **SNES** — clearest 15 kHz timing (`256×224`).
2. **PC Engine / PCE CD** — `512×240` (watch very wide line).
3. **FBNeo** — one ROM; if flat 640×480, switch ES core to **MAME** or set `fbneo.videomode`.
4. **Dreamcast / Naomi / Saturn / PSX** — expect 640×480 until `*.videomode` added.
5. **PS2 / PSP** — already configured; confirm picture.
6. **Windows** — one game per resolution bucket above.
7. **Vectrex / NES** — set `videomode` first, then test.

## Exit check (all systems)

After quit: menu **480×640** rotated (`640×480i` + rotate right). Wrong rotation = `gameStop` / symlink issue, not emulator-specific.

## Verify (read-only)

```bash
tail -5 /userdata/system/logs/display.log   # myzar gameStart: SYSTEM ROM -> MODE
grep "\.videomode=" /userdata/system/batocera.conf
export DISPLAY=:0; xrandr | grep -E "current|^[[:space:]]+[0-9]+x"
```

Do **not** run live `switchres` over SSH on a running session.
