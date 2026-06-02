# CRT Combo Mode Switch (Controller Combo to Switch CRT → HD)

**Session:** `2026-04-29_crt-combo-mode-switch`  
**Status:** MERGED — PR [#413](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/413) merged 2026-05-11 (`...  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** [#413](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/413) (MERGED) — see [pr-status.md](pr-status.md)

## What this is

When a handheld running CRT Mode is powered on without a CRT display attached (e.g. traveling, forgot to switch to HD Mode before leaving), the user gets a **permanent black screen**. The 15kHz CRT output cannot drive the handheld's built-in LCD. There is no way to switch to HD Mode without SSH access or plugging into a CRT.

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
