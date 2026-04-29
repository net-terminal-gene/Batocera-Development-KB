# CRT / HD display logging accuracy

## Agent/Model Scope

Composer; device validation via SSH when implementing log changes.

## Problem

Several logs used during HD/CRT and mode-switcher debugging can **disagree with each other** or with **live `batocera.conf` / `xrandr`**, which wastes time and invites false root-cause theories.

Target issues (high and medium priority from fix-ladder review):

1. **`BootRes.log`** can report an installer-style **boot resolution** (e.g. **768×576@25**) while **`global.videomode`** and **`xrandr`** show a **different CRT mode** (e.g. **480i** / **641×480**) after the mode switcher has applied **CRT** boot choices. Readers may treat **`BootRes`** as ground truth for “what mode am I in?”
2. **`BUILD_15KHz_Batocera.log`** **`EDID build:`** lines reflect **EDID generation** (e.g. **769×576** for **generic_15**), not necessarily the **active X11 mode** after a **Boot_480i** path. Correlating **`EDID build`** with **`xrandr`** without context is misleading.
3. **`display.log`** on **HD** can show **`Invalid output - none`** and **EmulationStation web server** timeout lines alongside otherwise successful **HDMI-2** setup. Noise makes it harder to spot real failures.

## Root Cause

TBD per subsystem (installer vs post-install logger; BUILD grep habits; `display.sh` / checker ordering).

## Solution

- **Align or document** each log’s semantics (what it guarantees vs what it does not).
- Where feasible, **emit a second line** or **post-switcher refresh** so **boot-resolution** logs reflect **`global.videomode`** after mode switcher commits, **or** clearly label installer-only lines as historical.
- **Contributor-facing note** (README fragment or `BUILD` comment block): **`EDID build`** is not “current raster.”
- **`display.log`**: reduce **`none`** invalid-output noise if config can be tightened; treat **ES timeout** only if it correlates with user-visible failure (otherwise document as benign).

## Files Touched

| Repo | File | Change |
|------|------|--------|
| TBD | TBD | TBD after research pins writers for **BootRes** and **`display.log`** |

## Validation

- [ ] After **HD→CRT** with **Boot_480i**, **`BootRes.log`** (or replacement line) matches **`batocera-settings-get global.videomode`** and **`xrandr`** primary mode, **or** docs state explicitly that **`BootRes`** is install-time only.
- [ ] Doc or in-log hint: **`EDID build:`** vs live mode.
- [ ] **`display.log`**: confirm whether **`none`** / timeouts are fixable or documented only.

## Out of scope (explicit)

- First-run empty **Boot** in mode switcher (**pre-fix 05** class).
- **`batocera-version`** capture artifacts (**`43ov`**).
- **`641` vs `640`** mode ID naming in reviews.
- Git workflow reminders.
