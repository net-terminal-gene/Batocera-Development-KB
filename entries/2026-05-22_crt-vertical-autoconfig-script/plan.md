# CRT vertical autoconfig script (libretro cores)

## Agent/Model Scope

Composer, `ssh-batocera`, Batocera-CRT-Script tree. **Repos:** `ZFEbHVUE/Batocera-CRT-Script` (installer / userdata hooks). **Out of scope for v1:** Myzar-only wrappers (`zzz-myzar-switchres.sh`, `batocera-resolution` symlinks); those stay documented in `2026-05-21_crt-myzar-dp-hybrid-switchres` only.

## Problem

Vertical CRT on **vanilla** Batocera + CRT Script needs consistent **`batocera.conf`** keys and **RetroArch per-core / per-content** files across several libretro systems (**PC Engine**, **PC Engine CD**, **SNES**, **FinalBurn Neo**, **Neo Geo** via FBNeo, **Vectrex** via vecx, etc.). Doing this by hand per title does not scale and is easy to get wrong (videomode strings, `ratio`, core options, rotation).

## Root Cause

TBD (likely: no single installer step today that applies a vetted vertical preset matrix for these cores; prior work lived in per-cabinet `batocera.conf` edits and one-off `config/` files).

## Solution

Add a **new script** (name TBD, invoked from CRT installer or documented post-install) under **Batocera-CRT-Script** that:

1. **Reads** the CRT mode catalog (or shells out to `batocera-resolution listModes`) and picks vetted defaults (e.g. global `256x224.*` for **PCE / PCE CD** and **SNES** where appropriate).
2. **Writes** or merges into `/userdata/system/batocera.conf`: system-level `*.videomode`, `*.ratio`, per-system `*.retroarch.*` overrides where needed (e.g. **`snes.retroarch.crt_switch_resolution`**, **`vectrex.retroarch.crt_switch_resolution`**, **`vectrex.retroarch.video_rotation`**), and any required `fbneo.*` / `neogeo.*` keys (without clobbering unrelated user keys).
3. **Creates** RetroArch drop-ins under `/userdata/system/configs/retroarch/config/<Core Display Name>/` or Batocera’s **`snes/`** / **`vectrex/`** append paths only for cores in scope (e.g. `Beetle PCE Fast`, `FinalBurn Neo`, **`Snes9x`**, optional per-ROM from manifest), with optional per-ROM files generated from a manifest (ROM basename → preset).
4. **Documents** exceptions (hi-res PCE modes, FBNeo titles that need per-ROM `videomode` or core options, Vectrex optional `videomode` / `ratio` alternates, SNES per-ROM `video_rotation` for horizontal-only games in a vertical set) in this session’s **`research/`** as the **recommended code change spec** before implementing the generator logic.

**`research/` contract:** Each sub-file lists concrete file paths, keys, and ordering rules so implementation can follow it line-by-line. No orphan opinions in `design/` until `research/` stabilizes.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | TBD shell script + doc | New vertical autoconfig path |
| Batocera-Development-KB | `entries/2026-05-22_crt-vertical-autoconfig-script/**` | Session + **Vectrex** + **SNES** `research/*-vertical-autoconfig.md` |

## Validation

- [ ] Dry-run mode prints planned `batocera.conf` diff + file list without writing
- [ ] Apply on test Batocera: PCE + PCE CD pick up global `videomode` from script output
- [ ] FBNeo + Neo Geo: no regression vs current `fbneo.video_allow_rotate` cabinet policy; per-ROM presets only where listed in `research/`
- [ ] Vectrex: merged **`vectrex.*`** keys match [vectrex-vertical-autoconfig.md](research/vectrex-vertical-autoconfig.md); no edits to other systems when `--only=vectrex`
- [ ] SNES: merged **`snes.*`** keys match [snes-vertical-autoconfig.md](research/snes-vertical-autoconfig.md); no edits to other systems when `--only=snes`
- [ ] Re-run script is idempotent (same result second time)
- [ ] Docs in CRT Script wiki or `BUILD_15KHz` log mention how to invoke the script
