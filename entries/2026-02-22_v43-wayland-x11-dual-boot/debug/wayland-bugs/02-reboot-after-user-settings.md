# 02 — Reboot After User Set eDP-1 and Backglass None

**Date:** 2026-02-21
**Context:** Full Batocera restart after user explicitly set Video Output=eDP-1 and Backglass=None in ES.

## batocera.conf (display-relevant lines)

```
Line  17: #display.rotate=0                   (commented — unchanged)
Line 242: #global.videomode=CEA 4 HDMI         (commented — unchanged)
Line 246: #global.videooutput=""                (commented — STILL NOT eDP-1)
Line 250: #es.resolution=""                    (commented — unchanged)
Line 384: display.brightness=100               (user-generated)
Line 385: global.videooutput2=none              (user-generated, Backglass=None)
```

**Line count:** 385 (unchanged from Step 01)

### KEY FINDING — Confirmed across reboot

`global.videooutput=eDP-1` is still NOT written to `batocera.conf`. This persists across reboot.
ES's Video Output = eDP-1 selection is NOT stored in `batocera.conf`.

## batocera-boot.conf (display-relevant)

```
es.resolution=800x1280.60.00      (NOW UNCOMMENTED — was commented in Step 00/01)
display.rotate.EDP=1              (NOW PRESENT — was absent in Step 01)
```

**Change from Step 01:** `S65values4boot` synced values at boot time. The sysconfig-level
`display.rotate.EDP=1` and `es.resolution` are now in `batocera-boot.conf`.

## wlr-randr

```
DP-1: Enabled: no (VGA adapter now visible)
eDP-1: Enabled: yes, 800x1280@60Hz, Transform: 270 (correct)
```

DP-1 now visible after reboot (CRT/VGA adapter connected).

## batocera-resolution

```
listOutputs:       DP-1, eDP-1
currentOutput:     eDP-1
currentResolution: 1280x800
```

## display.log — Key Behavior

1. **Labwc init:** `Found Primary Output: 'none'` — confirms `batocera.conf` has no primary output set
2. **First loop:** `Using pre-configured video outputs - , none,` — empty primary, none secondary
3. **First loop:** `First video output defaulted to - DP-1` — defaulted to DP-1 (first in checker list)
4. **Enabled DP-1, disabled eDP-1** — wrong output initially activated
5. **Hotplug event** — DP-1 disconnected, ES restarted
6. **Second loop:** `Default output 'DP-1' not connected. Finding first available.` — fell back to eDP-1
7. **Third loop:** `Restored last primary video output - eDP-1` — settled on eDP-1 after DP-1 hotplug cycle

### [Inference] Display.log reveals the root mechanism

Since `global.videooutput` is empty (auto), the Wayland display manager defaults to the first
output in the checker's settled list. When DP-1 (VGA adapter) is connected, it gets picked first,
causing a brief wrong-output activation followed by hotplug correction. Setting `global.videooutput=eDP-1`
explicitly in `batocera.conf` would prevent this cycling — but ES doesn't write it there.

## Diff from Step 01

| Setting | Step 01 | Step 02 | Change |
|---------|---------|---------|--------|
| `global.videooutput` (line 246) | `#global.videooutput=""` | `#global.videooutput=""` | No change — still not eDP-1 |
| `batocera-boot.conf es.resolution` | `#es.resolution=max-1920x1080` | `es.resolution=800x1280.60.00` | Synced by S65values4boot |
| `batocera-boot.conf display.rotate.EDP` | absent | `display.rotate.EDP=1` | Synced by S65values4boot |
| `wlr-randr DP-1` | not visible | Visible, disabled | CRT adapter now connected |
| `listOutputs` | eDP-1 only | DP-1, eDP-1 | DP-1 now detected |
