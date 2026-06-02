# Sony PlayStation Portable (PPSSPP libretro) — autoconfig spec (vanilla vertical)

## Canonical prior art

Cabinet-tested deployment (6-title roster, 2026-05-24 on v43 `10.23.6.210`):
[psp-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/psp-vertical-vanilla-v43.md)

## Reading this from a fresh install

The generator runs on a cabinet that already has:

- Vanilla Batocera v43 + CRT Script vertical install (`display.rotate=1`, correct CRT geometry + super-res ladder).
- PSP ROMs in `/userdata/roms/psp/`.
- No PSP BIOS required for most titles.

It must not touch the display profile, global rotation, videomodes, or any other system. It writes ten `psp.*` system-wide keys, core-wide `PPSSPP.cfg`, per-game `PPSSPP/*.cfg`, TATE-tier `remaps/PPSSPP/*.rmp`, and (conditionally) deploys `.state.auto` files from a packaged bundle.

## How this differs from prior autoconfigs

PSP is the **sixth recipe class**: **state-injection + two-tier rotation + per-game viewport + TATE input remap**.

| Concern | PSP (this spec) | Dreamcast | PSX |
|---------|-----------------|-----------|-----|
| Core | libretro `ppsspp` | libretro `flycast` | libretro `pcsx_rearmed` |
| Skip-menu autoload | `.state.auto` (TATE tier + optional per-title exceptions) | `.state.auto` all roster | n/a |
| Two-tier rotation | system `=3`; TATE titles `=0`; horizontal keep `=3` | system `=3`; in-game-TATE `=0` | system `=3`; Cave family `=0` + viewport |
| Custom viewport | TATE 480×640; horizontal 544×480 or 816×480 | fill keys only | 480×640 for Cave |
| Input remap | **TATE tier only** (90° CW D-pad) | none | none |
| Cross-version state risk | **Yes** — test per title; Space Invaders Myzar state hung on v43 | Myzar→v43 worked for DC roster | n/a |

Net mechanism: **ten system-wide keys + core `PPSSPP.cfg` + (TATE: cfg + rmp + optional state) OR (horizontal: cfg only) × N**.

## Config paths (Batocera v43)

| Layer | Path |
|-------|------|
| Per-system keys | `/userdata/system/batocera.conf` (`psp.*`) |
| Core-wide RA cfg | `/userdata/system/configs/retroarch/config/PPSSPP/PPSSPP.cfg` |
| Per-game viewport / rotation | `/userdata/system/configs/retroarch/config/PPSSPP/<Title>.cfg` |
| TATE input remap | `/userdata/system/configs/retroarch/config/remaps/PPSSPP/<Title>.rmp` |
| Save / state directory | `/userdata/saves/psp/` |
| Core (locked) | **`ppsspp`** libretro |

## Script should implement

### Step 1 — Set the ten `psp.*` system-wide keys (idempotent)

```bash
batocera-settings-set psp.emulator libretro
batocera-settings-set psp.core ppsspp
batocera-settings-set psp.ratio full
batocera-settings-set psp.videomode "$PSP_VIDEOMODE"    # default 960x480.60.00 on reference cab
batocera-settings-set psp.retroarch.video_rotation "$ROTATION"   # default 3
batocera-settings-set psp.retroarch.video_force_aspect false
batocera-settings-set psp.retroarch.crt_switch_resolution 0
batocera-settings-set psp.autosave 0
batocera-settings-set psp.retroarch.savestate_auto_load true
batocera-settings-set psp.retroarch.savestate_auto_save false
```

### Step 2 — Write core-wide `PPSSPP.cfg`

```bash
mkdir -p /userdata/system/configs/retroarch/config/PPSSPP
cat > /userdata/system/configs/retroarch/config/PPSSPP/PPSSPP.cfg <<'EOF'
crt_switch_resolution = "0"
savestate_auto_load = "true"
video_refresh_rate = "59.940060"
video_rotation = "3"
video_shader_enable = "true"
EOF
chmod 644 /userdata/system/configs/retroarch/config/PPSSPP/PPSSPP.cfg
```

### Step 3 — TATE-tier per-game cfgs + remaps

For each stem in `$TATE_ROSTER` (default: Star Soldier, Beta Bloc, Neo Geo Heroes Ultimate Shooting):

```bash
mkdir -p /userdata/system/configs/retroarch/config/PPSSPP
mkdir -p /userdata/system/configs/retroarch/config/remaps/PPSSPP

write_tate_cfg() {
  title="$1"
  cfg="/userdata/system/configs/retroarch/config/PPSSPP/${title}.cfg"
  rmp="/userdata/system/configs/retroarch/config/remaps/PPSSPP/${title}.rmp"
  cat > "$cfg" <<'EOF'
aspect_ratio_index = "24"
custom_viewport_width = "480"
custom_viewport_height = "640"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_rotation = "0"
video_force_aspect = "true"
video_scale_integer = "false"
remap_save_on_exit = "false"
input_remap_binds_enable = "true"
input_player1_right_btn = "16"
input_player1_down_btn = "19"
input_player1_left_btn = "17"
input_player1_up_btn = "18"
input_player1_analog_dpad_mode = "1"
EOF
  cat > "$rmp" <<'EOF'
input_player1_right_btn = "16"
input_player1_down_btn = "19"
input_player1_left_btn = "17"
input_player1_up_btn = "18"
EOF
  chmod 444 "$cfg" "$rmp"
}
```

Portrait dimensions (`480×640`) are cabinet-tested on the reference vertical CRT; recompute from `display.rotate` + active super-res if the generator targets a different mount.

### Step 4 — Horizontal-tier per-game cfgs (viewport only)

```bash
write_horizontal_cfg() {
  title="$1"
  width="$2"
  height="$3"
  extra="${4:-}"
  cfg="/userdata/system/configs/retroarch/config/PPSSPP/${title}.cfg"
  cat > "$cfg" <<EOF
aspect_ratio_index = "24"
custom_viewport_width = "${width}"
custom_viewport_height = "${height}"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_rotation = "3"
video_force_aspect = "true"
video_scale_integer = "false"
${extra}
EOF
  chmod 444 "$cfg"
}

# Default horizontal roster (reference cab):
write_horizontal_cfg "Pac-Man Championship Edition" 544 480 ""
write_horizontal_cfg "Super Stardust Portable" 544 480 ""
write_horizontal_cfg "Space Invaders Evolution" 816 480 'crt_switch_resolution = "0"
savestate_auto_load = "false"
'
```

Do **not** generate `.rmp` files for horizontal titles.

### Step 5 — Deploy state bundle (conditional)

```bash
if [ -n "$ASSET_DIR" ] && [ -d "$ASSET_DIR" ]; then
  rsync -av --include='*.state.auto' --include='*.state.auto.png' --exclude='*' \
    "$ASSET_DIR/" /userdata/saves/psp/
fi
```

**Default manifest excludes Space Invaders Evolution** from bundled states (`skip_states: [Space Invaders Evolution]`). Myzar-origin Space Invaders state hung v43 PPSSPP/RetroArch on autoload.

Only bundle states captured on the **same Batocera major version + PPSSPP core** as the target, or validate each title individually after deploy.

Recommended Mac-side TATE bundle source: `~/Batocera-Development-KB/snapshots/myzar-psp-states/` (Star Soldier, Beta Bloc, Neo Geo Heroes Ultimate Shooting only).

### Step 6 — Cleanup incompatible artifacts

```bash
# Remove known-bad cross-version state if re-running generator
rm -f "/userdata/saves/psp/Space Invaders Evolution.state.auto" \
      "/userdata/saves/psp/Space Invaders Evolution.state.auto.png" \
      /userdata/saves/psp/._*
```

## YAML manifest schema (suggested)

```yaml
psp:
  videomode: "960x480.60.00"
  rotation: 3
  tate_roster:
    - "Star Soldier"
    - "Beta Bloc"
    - "Neo Geo Heroes Ultimate Shooting"
  horizontal_roster:
    - name: "Pac-Man Championship Edition"
      viewport: [544, 480]
    - name: "Super Stardust Portable"
      viewport: [544, 480]
    - name: "Space Invaders Evolution"
      viewport: [816, 480]
      savestate_auto_load: false
  bundle_states: yes
  skip_states:
    - "Space Invaders Evolution"   # Myzar v41 state hangs v43 PPSSPP on autoload
  bundle_state_sources:
    tate_only: "assets/psp-states-tate/"
```

## Do NOT touch

- `psp.videomode` after operator calibration (unless manifest explicitly overrides)
- Existing operator-created `.state.auto` files not in the manifest replace list
- Other systems' `batocera.conf` keys
- Global `display.rotate` or CRT Script geometry outputs

## Validation targets

After generator run on reference cabinet:

1. `grep ^psp /userdata/system/batocera.conf | wc -l` → 10 lines
2. TATE title: cfg + rmp mode `-r--r--r--`, autoload reaches gameplay, D-pad rotated 90° CW
3. Horizontal title: cfg locked, no rmp, exit hotkey works
4. Space Invaders: no `.state.auto` present; cfg contains `savestate_auto_load = "false"`

## Risks for generator authors

- **PPSSPP savestate format is core-version-sensitive.** Unlike Saturn/Dreamcast where Myzar→v43 worked broadly, PSP requires per-title validation after core bumps.
- **RA remap persistence fights locked cfgs** unless `remap_save_on_exit=false` and `chmod 444` on both cfg and rmp.
- **ES PSP menu clobber** — document re-apply step or hook post-ES-save validator.
- **Horizontal controls unrotated** — document as accepted behavior, not a generator bug.

## Links

- Cabinet recipe: [psp-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/psp-vertical-vanilla-v43.md)
- Dreamcast two-tier rotation spec: [dreamcast-vertical-autoconfig.md](dreamcast-vertical-autoconfig.md)
