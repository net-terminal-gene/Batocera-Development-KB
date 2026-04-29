# 01 — User Explicitly Set eDP-1 and Backglass None

**Date:** 2026-02-21
**Context:** User set Video Output → eDP-1 and Multiscreens > Backglass > Video Output → None via ES System Settings menu.

## batocera.conf (display-relevant lines)

```
Line  17: #display.rotate=0                   (commented — unchanged)
Line 242: #global.videomode=CEA 4 HDMI         (commented — unchanged)
Line 246: #global.videooutput=""                (commented — STILL AUTO, NOT eDP-1)
Line 250: #es.resolution=""                    (commented — unchanged)
Line 384: display.brightness=100               (NEW — user-generated)
Line 385: global.videooutput2=none              (NEW — user-generated, Backglass=None)
```

**Line count:** 385 (was 383, +2 new user-generated lines)

### KEY FINDING

**`global.videooutput=eDP-1` was NOT written.** Line 246 remains `#global.videooutput=""` (commented/auto).

ES wrote `global.videooutput2=none` (Backglass) to the user-generated section at the bottom,
but did NOT write `global.videooutput=eDP-1` (primary Video Output) anywhere.

This means:
- The Backglass setting persists to `batocera.conf` → `global.videooutput2=none` ✓
- The primary Video Output setting does NOT persist to `batocera.conf` → `global.videooutput` remains commented ✗
- Any backup/restore mechanism that relies on `batocera.conf` having `global.videooutput=eDP-1` will fail to preserve the user's choice

### [Inference] Possible explanations:
1. On Wayland, ES may manage the primary video output through a different mechanism (labwc window rules, display checker state file) rather than `batocera.conf`
2. ES may only write `global.videooutput` when the value differs from the auto-detected default — and since eDP-1 IS the auto-detected output, ES may consider it redundant
3. ES may have a bug where selecting the already-active output doesn't trigger a config write

## User-generated section

```
system.cpu.governor=performance
display.brightness=100
global.videooutput2=none
```

## wlr-randr (unchanged from baseline)

```
eDP-1: Enabled, 800x1280@60Hz, Transform: 270
```

## batocera-resolution (unchanged)

```
listOutputs:       eDP-1
currentOutput:     eDP-1
currentResolution: 1280x800
```

## batocera-boot.conf (unchanged)

```
#es.resolution=max-1920x1080    (commented)
```

No `display.rotate` entries.

## Diff from Step 00

| Setting | Step 00 | Step 01 | Change |
|---------|---------|---------|--------|
| `global.videooutput` (line 246) | `#global.videooutput=""` | `#global.videooutput=""` | **NO CHANGE — eDP-1 NOT written** |
| `display.brightness` | absent | `100` | Added to user-generated |
| `global.videooutput2` | absent | `none` | Added to user-generated |
| Line count | 383 | 385 | +2 |
