# Disable 240p boot / EmulationStation resolution

## Agent/Model Scope

Composer; Batocera hardware QA by Mikey before commit/push per project workflow.

## Problem

Users pick `320x240` or `1280x240` as the main boot / ES resolution despite theme limitations, then ask for Discord support the team cannot satisfy.

## Root Cause

No EmulationStation theme reliably supports 240p vertical for the boot UI. Script previously listed 240p as a numbered choice like any other mode.

## Solution

- Detect rows matching `^[0-9]+x240@` in the EDID resolution list (both GPU matrices).
- Print a one-time callout (why disabled, Switchres unchanged, future re-enable, Discord policy).
- Render disabled rows without a selectable index; reject numeric input that maps to a disabled slot.

**CRT-Script git branch:** `crt-disable-240p-boot-resolution` (Batocera-CRT-Script repo only; KB stays on default branch as files under `entries/`).

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `userdata/system/Batocera-CRT-Script/Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` | `is_disabled[]`, callout, display + validation for EDID chooser |

## Validation

- [x] `bash -n` on `Batocera-CRT-Script-v43.sh` (2026-05-22, host)
- [ ] On CRT hardware: profile with 240p shows callout; disabled row has no index; valid indices unchanged
- [ ] Typing former 240p index re-prompts with disabled message
- [ ] In-game 240p via Switchres still works (spot-check one game)
