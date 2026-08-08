# BUA Fightcade Flatpak — Missing ROMs Directory

**Session:** `2026-08-07_bua-fightcade-flatpak-roms`
**Status:** TBD — PoC validated on batocera.local; next is publish install script repo
**Primary repo:** planned `net-terminal-gene/batocera-fightcade-flatpak` (Sunshine-style `curl \| bash`)
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

Flatpak Fightcade on Batocera hides ROMs under `.var` and does not wire host rom folders. Manual PoC proved: pre-create `data/ROMs`, symlink from `/userdata/roms` (with Flatpak filesystem overrides), and Fightcade reads those games. Plan is to encode that into a GitHub install script under net-terminal-gene, same delivery model as Sunshine Flatpak.

## Where to look

| File / folder | Purpose |
|---------------|---------|
| [plan.md](plan.md) | Problem, root cause, install-script plan, symlink map, checklist |
| [design/](design/) | Architecture for `install.sh` + arcade/console link model |
| [VERDICT.md](VERDICT.md) | Final outcome when the session closes |
| [pr-status.md](pr-status.md) | PR links, branch, merge state |
| [research/](research/) | Inventory, layouts, hash audits |
| [debug/](debug/) | Symlinks applied + launch notes |

Authoritative detail lives in **VERDICT.md** and **pr-status.md** once work is done; **plan.md** shows original intent vs what shipped.
