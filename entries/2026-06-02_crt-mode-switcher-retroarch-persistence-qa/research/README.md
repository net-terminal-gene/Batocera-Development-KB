# Research — Mode Switcher RetroArch Persistence QA

## Batocera RetroArch userdata layout

Root: `/userdata/system/configs/retroarch/` (`RETROARCH_CONFIG` in configgen).

| Path | Typical content | Good persistence test? |
|------|-----------------|------------------------|
| `config/remaps/<Core>/<name>.rmp` | Controller remaps | **Yes** (PR #438 baseline) |
| `config/remaps/<Core>/<Game>.rmp` | Per-game remap | **Yes** |
| `config/remaps/common/common.rmp` | Copy of custom cfg bindings | **Yes** |
| `config/<Core>/<Core>.cfg` | Per-core video/input (overlays, rotation) | **Yes** — CRT Script drops many here |
| `config/<system>/<rom>.cfg` | Per-game overrides | **Yes** |
| `megadrive.cfg`, `snes.cfg`, … | Per-system libretro cfgs | **Yes** |
| `cores/retroarch-core-options.cfg` | Global core options | **Yes** — change one core option in RA |
| `overlay.cfg` | Overlay index | **Yes** |
| `overlays/` | Border/overlay assets | **Yes** — large; mode-specific by design |
| `inputs/*.cfg` | Autoconfig | **Yes** if file exists |
| `retroarchcustom.cfg` | Launch config | **Poor test** — regenerated every game |
| `cache/` | RA cache | Low value |

## Settings that do NOT test mode-switch backup well

- **Global RA menu changes** with `config_save_on_exit=false` (Batocera default in `libretroRetroarchCustom.py`): may not write to disk.
- **Savestates / .srm**: under `/userdata/saves/`, outside swap tree.
- **`batocera.conf` keys** (`megadrive.core`, etc.): not in `configs/retroarch/`.

## Recommended test configs (non-remap)

### 1. Per-core `.cfg` (durable, visible in-game)

Path example (Mega Drive / Genesis Plus GX):

`/userdata/system/configs/retroarch/config/Genesis Plus GX/Genesis Plus GX.cfg`

Add a line you can verify in-game or in file after round trip:

```ini
# mode-switch QA marker
video_scale = "2.000000"
```

Or toggle something obvious: `runahead_frames = "1"` (if core supports).

### 2. Core options file

Path: `/userdata/system/configs/retroarch/cores/retroarch-core-options.cfg`

In RetroArch: Quick Menu → Options → change a Genesis Plus GX option (e.g. FM filter), then confirm the file updates on disk before switching modes.

### 3. Per-game `.cfg`

Path: `/userdata/system/configs/retroarch/megadrive/<RomName>.cfg`

Batocera uses system folder name + rom stem. Append a comment or non-default key after testing one game.

### 4. Per-system `.cfg`

Path: `/userdata/system/configs/retroarch/megadrive.cfg`

Used when launching any Mega Drive game (`--appendconfig`).

### 5. SSH marker file (sanity)

```bash
echo "crt-qa-$(date +%s)" > /userdata/system/configs/retroarch/config/.mode_switch_qa_marker
```

After CRT→HD→CRT, file must still exist with same content in CRT (proves tree restore). In HD, you see the **HD snapshot** tree (marker may be absent until you switch back).

### 6. Overlay / border (CRT-specific)

If CRT Script installed handheld borders:

`config/Genesis Plus GX/gamegear.cfg` or files under `overlays/borders/`

Expect **different** overlay sets in HD vs CRT; test that CRT border returns after CRT restore, not that HD has the same file.

## Shared remaps (Phase B) expected behavior

| Step | `config/remaps/` on live disk |
|------|------------------------------|
| Set remap in CRT | Present |
| Switch to HD (today) | Replaced by HD backup (often empty) |
| Switch to HD (Phase B) | **Still present** (unchanged) |
| Play game in HD | Uses same `.rmp` |
