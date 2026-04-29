# VERDICT — Mode Switcher Empty Backups

## Status: RESOLVED

## Summary

Confirmed as first-run behavior, not a bug. Backup files don't exist until the first complete mode switch cycle. After one full CRT→HD→CRT round trip, all backups populate correctly (25 CRT files, 11 HD files) and subsequent runs skip straight to the summary.

During this investigation, two additional bugs were discovered and split into separate KB entries:
- `2026-04-08_crt-installer-missing-videooutput` — Installer never writes `global.videooutput` to `batocera.conf`
- `2026-04-08_crt-mode-switcher-truncated-videomode` — Truncated `global.videomode` causes ES to show "Auto"

## Plan vs reality

No code changes needed. The original concern (forced re-picking) was expected first-run behavior.

## Root Causes

1. Backup files are only written after a complete wizard flow in `run_mode_switch_ui()`.
2. On first run, all backup directories are empty, causing `check_mandatory_configs()` to flag all settings as unconfigured.

## Changes Applied

| File | Change |
|------|--------|
| (none) | No code changes — behavior is by design |
