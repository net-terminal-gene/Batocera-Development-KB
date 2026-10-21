# Fightcade Flatpak — CSS Vertical (TATE) Lobby Mode

**Session:** `2026-09-30_fightcade-css-vertical-mode`
**Status:** MERGED via PR #4 (2026-10-09, `fa05fd5`)
**Primary repo:** [net-terminal-gene/batocera-fightcade-flatpak](https://github.com/net-terminal-gene/batocera-fightcade-flatpak)
**Branch:** `vertical-build` (was `feat/css-vertical-mode` locally)
**PR:** [#4](https://github.com/net-terminal-gene/batocera-fightcade-flatpak/pull/4) — see [pr-status.md](pr-status.md)

## What this is

Maintainer notes for the Fightcade Flatpak **vertical / TATE lobby** (ES `fcvertical`, CRT only). The lobby is a Nativefier wrap of `web.fightcade.com`. Vertical mode rotates the page 90° in `lobby/inject.js`. This session covers rotated overlays (tooltip, cursor, `<select>`), pad cursor-axis remap, zoom-aware fit with separate landscape vs vertical lobby zoom (Text menu), room stack Looking to Play 40% / Chat 60%, FBNeo `nVidRotationAdjust` persistence, and CRT-only install of `es_features_fightcade_vertical.cfg`. Docs: `docs/CRT-VERTICAL.md`. Shares PR #4 with `2026-09-30_fightcade-vertical-library`.

## Where to look

| File / folder | Purpose |
|---------------|---------|
| [plan.md](plan.md) | Problem, approach, files touched, validation checklist |
| [VERDICT.md](VERDICT.md) | Final outcome when the session closes |
| [pr-status.md](pr-status.md) | PR #4, branch `vertical-build` |
| [research/](research/) | Markup, rotation math, zoom persistence |
| [design/](design/) | Transform, overlays, zoom storage |
| [debug/](debug/) | SSH verification, failure signs |
