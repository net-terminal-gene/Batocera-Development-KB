# Mode Switcher: Empty Backups on First Run

## Agent/Model Scope

Composer + ssh-batocera for live system verification.

## Problem

Running `mode_switcher.sh` forces the user to re-pick all three mandatory settings (HD output, CRT output, boot resolution) because backup files don't exist yet.

## Root Cause

The backup directories exist but contain zero files until the first complete mode switch cycle. `check_mandatory_configs()` sets `NEEDS_*_CONFIG=true` for any empty value, and with all backup files missing and `batocera.conf` lacking `global.videomode`/`global.videooutput`, all three flags are set to `true`.

Confirmed via SSH: after completing one full CRT→HD→CRT round trip, all backups populated correctly (25 CRT files, 11 HD files), and subsequent mode switcher runs skip straight to the summary.

## Solution

No fix needed — first-run re-pick behavior is expected. Backups populate after the first complete cycle.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| (none) | — | First-run behavior, not a bug |

## Validation

- [x] Run mode_switcher.sh — verify it skips to summary when settings already exist
- [x] Cancel at summary, re-run — verify settings are still remembered
- [x] Complete a full mode switch cycle — verify backups are populated (CRT: 25 files, HD: 11 files)
