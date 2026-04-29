# PR Status - Mode Switcher Empty Backups

## No Separate PR (Design Investigation)

**Status:** RESOLVED — First-run behavior is by design. Related bugs discovered and fixed via PR #395.

During this investigation, two additional bugs were identified:
- `2026-04-08_crt-installer-missing-videooutput` — FIXED in PR #395 (bootstrap session)
- `2026-04-08_crt-mode-switcher-truncated-videomode` — FIXED in PR #395

After one full CRT → HD → CRT roundtrip, all backups populate correctly (25 CRT files, 11 HD files).
