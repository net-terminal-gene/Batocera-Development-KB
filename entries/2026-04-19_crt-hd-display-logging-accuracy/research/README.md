# Research — CRT / HD display logging accuracy

## Findings

### 1. `BootRes.log` vs live CRT mode

From fix-phase doc **`../2026-04-18_v43-edid-amd-matrix-mismatch/debug/fix/11-crt-mode-pre-mode-switcher.md`**:

- **`BootRes.log`:** `Boot Resolution: 768x576@25` (installer-style line).
- **`batocera.conf` / `xrandr`:** **480i** path (**`641x480.60.00052`**, **641×480** on **DP-1**).

**Implication:** **`BootRes`** is not updated to reflect mode-switcher-driven **`global.videomode`**, or it records a different phase of boot than the running session.

### 2. `EDID build:` vs `xrandr`

Same **11** capture: **`BUILD`** grep still shows **`switchres 769 576 25`** for **generic_15** while **X** runs **641×480**.

**Implication:** **`EDID build`** is tied to **EDID** generation, not to the **active Boot_*** desktop mode after user choice.

### 3. `display.log` on HD

From **`debug/fix/04`**, **`09`**, **`13`**: **`Explicit video outputs configured ( HDMI-2 none)`** → **`Invalid output - none`**; occasional **`Timed out waiting for EmulationStation web server`**.

**Implication:** Distinguish benign ordering noise from real failures; locate writer in **`batocera-display`** / **Batocera** scripts before changing strings.

## Next research steps

- [ ] Grep **Batocera-CRT-Script** and **batocera** payloads for **`BootRes.log`** writer and when it runs.
- [ ] Confirm whether **`BootRes`** should be append-only, overwritten on each boot, or replaced after mode switcher.
- [ ] Trace **`none`** output path in **`display.log`** for **HD** with **`videooutput2=none`**.
