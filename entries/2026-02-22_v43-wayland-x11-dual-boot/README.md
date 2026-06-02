# v43 Steam Deck Wayland/X11 Solution Plan (Overlay-Focused)

**Session:** `2026-02-22_v43-wayland-x11-dual-boot`  
**Status:** TBD (see VERDICT.md)  
**Primary repo:** batocera.linux  
**PR:** [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) (MERGED) — see [pr-status.md](pr-status.md)

## What this is

- Batocera v42 introduced `VariableRefresh true` in the amdgpu Xorg config, causing persistent screen tearing on Steam Deck (AMD Van Gogh) X11 builds. Exhaustive testing (13 driver/kernel-param combos, TearFree, vblank_mode, Mesa VK present mode) failed to resolve it on v42/v43 X11. - Batocera v43 Steam Deck will use Wayland by default for HD Mode, which eliminates the X11 tearing issue for HD use. - CRT Mode requires X11 (switchres, 15 kHz, xrandr). - The CRT Script currently assumes X11 and breaks on Wayland builds. - The dual-boot approach solves both problems: Wayland for HD (no tearing), X11 for CRT (switchres/xrandr).

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
