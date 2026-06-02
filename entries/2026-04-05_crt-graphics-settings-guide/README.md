# CRT Graphics Settings Guide for Modern PC Games

**Session:** `2026-04-05_crt-graphics-settings-guide`  
**Status:** IN PROGRESS  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

Modern PC games have dozens of graphics settings designed for HD/4K LCD/OLED displays. When outputting to a 15 kHz CRT television at 480i via HDMI-to-component, many of these settings produce no visible improvement while consuming significant GPU resources. No consolidated reference existed for which settings matter on CRT and which are wasted.

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
