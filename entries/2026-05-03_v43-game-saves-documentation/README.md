# v43 game saves layout (documentation for upstream)

**Session:** `2026-05-03_v43-game-saves-documentation`  
**Status:** TBD (see VERDICT.md)  
**Primary repo:** batocera.linux  
**PR:** [#15670](https://github.com/batocera-linux/batocera.linux/pull/15670) (MERGED) — see [pr-status.md](pr-status.md)

## What this is

1. **Original scope:** Map **where v43 persists userdata / saves** vs v42 for upstream (see **`v42-x86_64-snapshot.md`**). 2. **Additional finding:** **Steam games not appearing in ES on v43** is explained by **`batocera-steam-update`** scanning **`flatpak/data/Desktop/`** after upstream commit **`ab1a8b85f9`**, while **v42’s deployed script still scans `.../.local/share/applications`**, and Flatpak Steam commonly places game **`.desktop`** files under **`applications`**, not **`Desktop`**.

## Where to look

| File / folder | Purpose |
|---------------|---------|
| [plan.md](plan.md) | Problem, approach, files touched, validation checklist |
| [VERDICT.md](VERDICT.md) | Final outcome when the session closes |
| [pr-status.md](pr-status.md) | PR links, branch, merge state |
| [research/](research/) | Investigation notes and system findings |
| [design/](design/) | Architecture and flow |
| [debug/](debug/) | Test logs, repro steps, failure signs |

Authoritative detail lives in **VERDICT.md** and **pr-status.md** once work is done; **plan.md** shows original intent vs what shipped.
