# Design — CRT SF6 / ms929 Display Mode Parity

## Architecture (what must match)

```mermaid
flowchart LR
  subgraph bc250 [BC-250 golden]
    SR1[Switchres / CRT Script]
    X1[XRandR DP-1: 3 modes]
    SF1[SF6 config.ini DisplayModeCount=3]
    W1[Borderless 854x480 window]
    SR1 --> X1 --> SF1 --> W1
  end

  subgraph rx7700 [RX 7700 target]
    SR2[Switchres / CRT Script]
    X2[XRandR DP-2: many junk modes]
    SF2[SF6 DisplayModeCount=13+ index0=320x180]
    W2[Soft upscale]
    SR2 --> X2 --> SF2 --> W2
  end

  X2 -.->|Phase B allowlist| X1like[XRandR DP-2: 3 modes]
  X1like --> SFok[DisplayModeCount=3 index0=640x480]
```

## Fix flow (agent checklist)

1. **Read-only audit** on 7700 (same script as BC-250).
2. **Mode allowlist on CRT connector** until `xrandr` ≤ 3 modes.
3. **Relaunch SF6**; confirm `config.ini` regenerates with `DisplayModeCount=3`.
4. **Set/keep** golden `config.ini` keys (Borderless, TAA, IQ=1, etc.).
5. **Optional:** Flatpak Steam + Proton Experimental to match launch path.
6. **Fix stale** `global.videooutput=DP-2` if still `DP-5`.
7. **Never** loop-kill ES / force ES to 854 as an SF6 fix.

## Mode allowlist target

Keep only:

| Mode name (example) | Role |
|---------------------|------|
| `641x480i` | EDID preferred / Boot_480i |
| `641x480` | Progressive sibling |
| `SR-1_854x480@60.00i` or Switchres `854x480.60.00068` | Steam / SF6 desktop |

## Why sed-on-index fails

```
Launch → SF6 enumerates X modes → rewrites DisplayMode* → may set FullScreenDisplayMode=0
Exit   → SF6 writes config.ini again
```

If mode 0 is 320×180, every “fix the index” is temporary. Shorten the list so **0 is safe**.
