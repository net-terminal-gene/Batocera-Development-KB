# Debug — Cursor issues and verification

## Symptoms vs likely cause

| Symptom | Likely cause |
|---------|----------------|
| Move–stop–move in **lobby** (Deck HD) | Heavy `refresh()` every frame (historical: 3× pgrep at ~60 Hz) |
| Stutter in **Test Mode** windowed FBNeo | xdotool/pgrep every frame + compositor hide/warp fighting uinput |
| Frozen / no cursor | `fightcade-pad-mouse.disable` present; stale daemon; pointer at 0,0 after bad warp |
| “Sliders do nothing” | ES settings not saved (closed popup with LAUNCH only); or overlay cleared on gameStop before retest |
| “Cursor feels slow” | Loop starvation before speed tuning; check `/tmp/pad-mouse.log` frame timing |

## Enable verbose logging

1. ES → Fightcade Advanced → **FIGHTCADE DEBUG LOGGING** ON
2. Close popup to game list, launch Fightcade
3. Touch `/tmp/fightcade-debug.on` should exist
4. Log: `/tmp/pad-mouse.log` (and collected report under `/userdata/system/logs/` on gameStop)

## Quick checks (SSH)

```bash
pgrep -af fightcade-pad-mouse
test -f /userdata/system/fightcade-flatpak/fightcade-pad-mouse.disable && echo DISABLED
cat /tmp/fightcade-cursor-speed.conf 2>/dev/null
tail -30 /tmp/pad-mouse.log
```

## Deck vs PC regression guard

Any change to `refresh()`, pointer backend, or SELECT+Start must keep **`_refresh_pc_legacy()`** on non-`wayland_hd_session()` paths. Verify PC CRT box lobby + SELECT+Start quit after Deck work.

## Resolved (2026-09) Deck HD

Lobby + Test Mode validated after gating Deck fixes behind `wayland_hd_session()`. Root cause write-up: see session **research/** and **design/** refresh split.

## Resolved 2026-09-26 — cursor missing after SELECT+Start from fullscreen (Deck HD)

**Report:** Test Mode → in-emulator menu cursor fine → fullscreen gameplay (no cursor, expected) → SELECT+Start (Alt+F4) back to lobby → **cursor gone**. Happened with and without an external pad.

**Evidence (SSH, no guessing):**

- Platform: labwc/Xwayland, `DISPLAY=:0.0`, uinput pointer backend.
- No leftover emulator/wine process; Fightcade lobby (`fc2-electron`) was the **active window**.
- Pointer on-screen at `x:134 y:333` over the lobby → focus/position were fine.
- `/tmp/fightcade-cursor-wayland.state` = **`hidden`** → the cursor image was in labwc's hidden state.

**Root cause:** Fullscreen game left the labwc cursor hidden (`WL_STATE=hidden`). On the Wayland-HD path `set_cursor_visible()` is a deliberate no-op (HideCursor warps), so **nothing re-showed the cursor** when returning to the lobby. Alt+F4 quit the emulator but never restored the pointer.

**ShowCursor is warp-free:** ran `fightcade-cursor show` (labwc `A-W-s`); `WL_STATE`→`visible` and pointer stayed at `134,333` (no warp). Only HideCursor (`A-W-h`) warps.

**Fix:** `input/fightcade-pad-mouse` — new `force_cursor_show(display)` (always calls `fightcade-cursor show`, bypassing the Wayland-HD no-op). Called after **both** SELECT+Start / Alt+F4 branches (Deck and PC), sets `cursor_visible=True`. See `code-changes/`.

**Verified:** deployed to device, remote `py_compile` OK; user confirmed cursor returns on SELECT+Start. Activates on next Fightcade launch (fresh daemon), no mid-session restart required.

### Recovery command (if it ever happens again pre-fix)

```bash
WAYLAND_DISPLAY=wayland-0 XDG_RUNTIME_DIR=/var/run \
  /userdata/system/fightcade-flatpak/input/fightcade-cursor show
```
