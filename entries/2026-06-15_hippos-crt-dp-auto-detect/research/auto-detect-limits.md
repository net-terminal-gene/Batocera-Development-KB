# CRT auto-detect limits — why manual setup is required

## What HippOS tries today

`hippos-display-setup` `_crt_auto_detect()`:

- Connector must be **VGA-* or DVI-I-***
- **0-byte EDID** on that connector
- → run `hippos-crt-setup`

Theory: LCDs send EDID; dumb CRT paths often do not.

## What it cannot detect

| Question | Answer |
|----------|--------|
| Is a **DAC** connected on DisplayPort? | **No** — no `dac_connected` in DRM sysfs |
| CRT vs HD on **same DP port**? | **Not directly** — only EDID presence/absence |
| Which port if **two outputs** connected? | **Ambiguous** without user picking `crt.output` |

## DP + DAC typical signals

| Downstream | EDID on DP (before OS injects firmware) |
|------------|----------------------------------------|
| HD monitor on DP | 128+ bytes (real monitor) |
| DAC + CRT, no DDC | **0 bytes** (may infer “no digital monitor”) |
| After HippOS CRT setup | **128 bytes fake EDID** (`Switchres200` / `generic_15` via `drm.edid_firmware`) |

Zero-byte EDID ≠ “DAC detected.” It means **no monitor identity on DDC**.

Adding DP to auto with rule **“connected + 0-byte EDID”** can work for DAC+CRT **before** firmware EDID is loaded. It does **not** identify a DAC. Picking **“first connected DP”** without EDID check would wrongly CRT-enable on HD monitors.

## Design implication

Match Batocera CRT Script: **user declares** CRT enable + output + profile (+ boot resolution). Auto remains optional at best for single native VGA, zero-EDID edge case only.

See `design/crt-es-settings-proposal.md` for recommended ES UX.
