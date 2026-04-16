# Debug 01 — Set Video Output: eDP-1 (Wayland, Pre-Script)

## Date: 2026-04-13

## Action

User went into Batocera System Settings (Wayland/HD mode) and set **Video Output = eDP-1** (Steam Deck internal display). No Video Mode was set — only the output.

## batocera.conf State After Setting

```
global.videomode  = (empty — not set)
global.videooutput = eDP-1
es.resolution     = (empty — not set)
```

### Raw relevant lines from batocera.conf

```
#global.videomode=CEA 4 HDMI
global.videooutput=eDP-1
```

## Resolution ID State (Wayland)

```
batocera-resolution listModes  = (empty — does not work in Wayland without X display)
batocera-resolution currentMode = (empty)
es.resolution                  = (empty — no Video Mode was selected, only Video Output)
global.videomode               = (empty)
```

### batocera-drminfo current output (Wayland)
```
0.0:EDP 800x1280 60Hz (800x1280*)   ← eDP-1, ACTIVE at Steam Deck native res
```
(DP-1 not yet plugged in at this stage)

**Key observation:** Selecting "Video Output = eDP-1" in ES System Settings writes `global.videooutput=eDP-1` to batocera.conf but does NOT write `global.videomode` or `es.resolution`. In Wayland, resolution is handled by the compositor — ES doesn't expose or save a videomode ID when the output is set.

## Observations

- `global.videooutput` is now `eDP-1` — written by ES when user selected the output in System Settings.
- `global.videomode` remains unset (only a commented-out factory placeholder `#global.videomode=CEA 4 HDMI` exists).
- `es.resolution` is not set — no resolution was configured.
- No `es.resolution` means batocera will use auto/default resolution for ES.

## Significance for Bootstrap Design

This confirms the factory Wayland state that the installer will encounter:
- `global.videooutput=eDP-1` will be present in `batocera.conf` when the user runs the CRT script.
- This is the value the bootstrap Step 1 needs to **capture** as the HD backup before overwriting with `DP-1`.
- `global.videomode` is absent — HD backup should store `default` as the fallback value.

## Next Stage

→ `02-script-run-no-bootstrap.md` — Run the original CRT script (no bootstrap changes), capture state post-install before reboot.
