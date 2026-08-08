# CRT SF6 / ms929 Display Mode Parity

## Agent/Model Scope

Composer + `ssh-batocera` skill. Hosts:

| Role | How to reach | GPU |
|------|----------------|-----|
| **Good (golden)** | `~/bin/ssh-batocera.sh 10.23.6.116` | AsRock BC-250 (RADV GFX1013) |
| **Bad (target)** | `~/bin/ssh-batocera.sh batocera.local` | RX 7700 XT + unused RTX 3090 |

Password/auth via `~/bin/ssh-batocera.sh`. Prefer scp’d scripts over complex remote quoting.

## Problem

SF6 on the RX 7700 XT CRT machine looks soft/pixelated (“like ass”) compared to the BC-250 on the same ms929 CRT path. In-game settings feel like they do nothing. ES/display thrash during diagnosis made things worse temporarily; configs were restored toward CRT defaults, but SF6 image quality on the 7700 box was never matched to BC-250.

## Root Cause

**Primary (measured):** SF6 stores resolution as `FullScreenDisplayMode=<index>` into a mode list it rebuilds from the OS/XRandR modes.

- **BC-250:** X exposes **3** modes → SF6 `DisplayModeCount=3`, index `0` = **640×480**. Window fills **854×480** borderless. Looks sharp.
- **RX 7700:** X exposes **many** junk modes (320×180, 320×240, …) → SF6 `DisplayModeCount=13+`, index `0` = **320×180**. Game often rewrites the index back to `0` on launch/exit. Looks like a postage stamp stretched to the desktop.

**Not the root cause (ruled out by audit):**

- Different SF6 build — same `buildid` `23395122`, same `StreetFighter6.exe` MD5 `fbd76345e90639aace9e3583c1d514ac`
- Missing quality presets — BC-250 uses TAA + DoF + Bloom + ImageQualityRate=1; matching those alone does not fix the 7700 box
- “7700 too weak” — same DX12→vkd3d path; game binds RADV on both

**Secondary differences (may matter for parity, not the soft image itself):**

| Item | BC-250 | RX 7700 |
|------|--------|---------|
| Steam | Flatpak + Proton Experimental 11.0-100 | BUA add-ons Steam (RunImage) |
| GPU count | 1 | 2 (3090 blacklisted at boot; DP renumber DP-5→DP-2) |
| `global.videooutput` | `DP-1` (matches live) | Often still `DP-5` while live is `DP-2` |
| Launch | `Street Fighter 6.steam` → `steam://rungameid/1364780` | Custom `1364780_Street_Fighter_6.sh` with prune/force hooks |

## Solution

**Do this — in order — on the RX 7700 box. Do not thrash ES/videomode in a loop.**

### Phase A — Prove parity gap (5 minutes, read-only)

1. Power on 7700 box.
2. Run the same audit script used on BC-250 (see `debug/README.md`).
3. Confirm:
   - `xrandr --current` mode count ≫ 3
   - `config.ini` `DisplayMode0` is tiny (e.g. 320×180)
   - Window size vs `FullScreenDisplayMode` index

### Phase B — Make X expose only BC-250-like modes (the real fix)

Target XRandR list on the active CRT connector (`DP-2` today):

```
641x480i
641x480
SR-1_854x480@60.00i   (or equivalent 854x480 Switchres mode)
```

Approaches (try in order; stop when `xrandr` shows ≤3 modes and SF6 rewrites `DisplayModeCount=3`):

1. **Switchres / CRT Script mode generation** — find why Navi32 adds every super-resolution / junk mode to X while BC-250 does not. Align `switchres.ini` / monitor type `ms929` / generation flags with the BC-250 machine. Prefer fixing generation over deleting modes after the fact (xrandr `--delmode` previously returned `BadAccess` and did not stick).
2. **Launch-time mode allowlist** — before Steam/SF6 starts, ensure only the three modes exist (re-add SR-1_854 if needed via `batocera-resolution setMode 854x480.60.00068`, then remove others if the driver allows). Verify with `xrandr` **before** `StreetFighter6.exe` starts.
3. **Do not rely on sed-only `FullScreenDisplayMode=12`** — game rewrites index on start/exit; without a short mode list, index `0` stays lethal.

### Phase C — Align Steam/Proton path (after Phase B works, or if B is blocked)

BC-250 golden path:

- Flatpak Steam
- Proton Experimental 11.0-100
- No Launch Options
- Single `config.ini` next to the exe

On 7700: either reinstall/use Flatpak Steam for SF6 (symlink game depot if needed to avoid redownload), or keep BUA but ensure Proton Experimental + same env class. Flatpak was tried earlier and did not alone fix image quality — **mode list is still required**.

### Phase D — Sync `config.ini` to golden values (only after modes are short)

Copy BC-250 key values (see `research/bc250-golden-reference.md`). Critical after short list:

```
FullScreenDisplayMode=0          # now means 640x480
WindowMode=Borderless
ImageQualityRate=1
AntiAliasing=TAA
UpscaleType=None
Capability=DirectX12
```

### Phase E — Leave ES alone

ES CRT boot path on both boxes wants `es.resolution=641x480.60.00082` / Boot_480i. Steam game path uses `steam.videomode=854x480.60.00068`.  
**Do not** force ES to 854 to “fix” SF6. **Do not** kill ES with overlapping restarts (caused black/flashing).

### Explicit non-goals

- More AA/DoF/Bloom toggling as the primary fix
- Exclusive fullscreen experiments (previously soft/crashy on this path)
- Removing the 3090 mid-debug unless Phase B needs a clean single-GPU boot test

## Files Touched (expected on 7700 box)

| Location | Change |
|----------|--------|
| X / Switchres / CRT Script mode gen | Restrict modes on DP-2 |
| `/userdata/roms/steam/1364780_Street_Fighter_6.sh` | Allowlist modes before launch; drop ineffective prune if unused |
| SF6 `config.ini` | Match golden keys after mode list is short |
| `/userdata/system/batocera.conf` | Keep `steam.videomode=854x480.60.00068`; fix `global.videooutput=DP-2` if still `DP-5` |
| Optional: Flatpak Steam | Match BC-250 stack |

## Validation

- [ ] On 7700: `xrandr --current` shows ≤3 modes on CRT connector while SF6 runs
- [ ] On 7700: `config.ini` has `DisplayModeCount=3` and `DisplayMode0=640×480` (or 641/854 only)
- [ ] On 7700: `FullScreenDisplayMode=0` after a full quit/relaunch (game rewrite must still land on a real 480p mode)
- [ ] SF6 window geometry is 854×480 (or fills desktop) via `wmctrl -lG` / `xwininfo`
- [ ] Visual: menu + match look comparable to BC-250 (same CRT/ms929)
- [ ] ES still boots cleanly at Boot_480i; no dual openbox / flashing
- [ ] Side-by-side audit: `research/` updated with 7700 post-fix dump
