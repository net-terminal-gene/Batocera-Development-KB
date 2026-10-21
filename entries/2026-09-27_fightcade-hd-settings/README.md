# Fightcade Flatpak — HD Video Settings Reference

**Session:** `2026-09-27_fightcade-hd-settings`
**Status:** MERGED via PR #3 (2026-09-29)
**Primary repo:** [net-terminal-gene/batocera-fightcade-flatpak](https://github.com/net-terminal-gene/batocera-fightcade-flatpak)
**PR:** [#3](https://github.com/net-terminal-gene/batocera-fightcade-flatpak/pull/3) — see [pr-status.md](pr-status.md)

## What this is

Reference documentation for how the Fightcade Flatpak installer configures HD (LCD / HDMI / Steam Deck) video output for the four Windows emulators it ships (snes9x, FBNeo, ggpofba, flycast). Fightcade's stock emulator defaults are windowed 640x480, menu-bar-visible, wrong aspect, and no vsync, so `hd/patch-hd-video.sh` plus the preset files under `hd/presets/` bring each emulator up to fullscreen at the panel's native resolution with correct 4:3 aspect and vsync. This session also captures the `snes9x [Config] Lock=TRUE` bug that silently discarded controller remaps, its root cause, and the fix (Lock=FALSE + trimming the patcher down to only panel-specific values).

## Where to look

| File / folder | Purpose |
|---------------|---------|
| [plan.md](plan.md) | Problem, root cause, solution, files touched, validation checklist |
| [VERDICT.md](VERDICT.md) | Final outcome when the session closes |
| [pr-status.md](pr-status.md) | PR links, branch, merge state |
| [research/](research/) | Stock defaults vs patched values, symlink/config-path findings |
| [design/](design/) | How presets + patcher + CRT switchres divide responsibility |
| [debug/](debug/) | SSH evidence, verification commands, failure signs |

Authoritative detail lives in **VERDICT.md** and **pr-status.md** once work is done; **plan.md** shows original intent vs what shipped.
