# VERDICT -- CRT EmulationStation Theme for 320x240

## Status: TBD

## Summary

Session created 2026-04-09. Research phase completed quickly: identified theme architecture (external GitHub repos, ES normalized coordinates, `tinyScreen` boolean, subset system). Implementation started 2026-04-11. Distribution approach pivoted from standalone fork to patching the stock Carbon theme directly during CRT Script installation. `crt240p.xml` layout iterated and tested at 640x480 on the Philips CRT via the `es-theme-carbon-crt` dev repo. Installer logic (v42 + v43) written and committed to `es-carbon-240-install` branch. PR #409 opened as draft. Pending validation at native 320x240.

## Plan vs reality

Original plan (Option A): standalone fork of Carbon deployed to `/userdata/themes/es-theme-carbon-crt/`. Actual approach: installer patches the stock theme at `/usr/share/emulationstation/themes/es-theme-carbon/` directly, avoiding the need for users to install a separate theme. The `crt240p` subset has no `tinyScreen` gate (available at all resolutions), differing from the original plan which assumed a tinyScreen-gated variant.

## Root Causes

TBD -- no bugs encountered in implementation phase yet.

## Changes Applied

| File | Change |
|------|--------|
| `Batocera-CRT-Script/Geometry_modeline/crt240p.xml` | New layout file -- fonts and positions tuned for 320x240 on 15kHz CRT |
| `Batocera-CRT-Script-v42.sh` | Copy crt240p.xml, inject subset block into theme.xml, write es_settings.cfg, backup/restore arrays |
| `Batocera-CRT-Script-v43.sh` | Same as v42 |
| `es-theme-carbon-crt/layouts/crt240p.xml` | Dev iteration of layout (source of truth for Geometry_modeline/crt240p.xml) |
| `es-theme-carbon-crt/theme.xml` | Added crt240p subset block (dev reference; stock theme patched at install time) |
