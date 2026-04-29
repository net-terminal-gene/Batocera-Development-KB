# PR Status - CRT Mode Switcher: First-Run Pre-Selects eDP-1 as CRT Output

## No Separate PR (Resolved via Installer Bootstrap)

**Status:** FIXED via `2026-04-11_crt-installer-videomode-bootstrap` work

Fix bundled into PR #395 during merge. The installer now pre-seeds `global.videooutput` and backup seed files, so first-run mode switcher correctly displays CRT output without guessing.
