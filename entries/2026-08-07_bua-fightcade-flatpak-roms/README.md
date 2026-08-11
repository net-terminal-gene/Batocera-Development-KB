# Fightcade Flatpak (Flathub) — ROMs + Batocera integration

**Session:** `2026-08-07_bua-fightcade-flatpak-roms` (slug legacy; **not** BUA Wine Fightcade)
**Status:** **BETA** — repo published; CRT Switchres needs community validation
**Primary repo:** [net-terminal-gene/batocera-fightcade-flatpak](https://github.com/net-terminal-gene/batocera-fightcade-flatpak)
**PR:** None (standalone install repo) — see [pr-status.md](pr-status.md)

## What this is

Flatpak Fightcade on Batocera hides ROMs under `.var` and does not wire host rom folders. This project ships a Sunshine-style installer that symlinks `/userdata/roms` into the Flatpak data tree, adds gamepad navigation, HD video defaults, and a **CRT Switchres wrapper** around gameplay (requires Batocera-CRT-Script). It does **not** change the Fightcade client UI.

## Where to look

| File / folder | Purpose |
|---------------|---------|
| [plan.md](plan.md) | Original problem + symlink map (CRT was out of scope at start; now shipped) |
| [pr-status.md](pr-status.md) | Repo link, commits, validation matrix, beta status |
| [VERDICT.md](VERDICT.md) | Final outcome when beta closes |
| [design/](design/) | Install architecture |
| [research/](research/) | ROM layout, hash audits |
| [debug/](debug/) | Early symlink PoC on batocera.local |

Authoritative live status: **pr-status.md** and the GitHub repo README.
