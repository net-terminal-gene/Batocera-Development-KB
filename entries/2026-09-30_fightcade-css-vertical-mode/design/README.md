# Design — Fightcade Flatpak CSS Vertical (TATE) Lobby Mode

## Rotation transform

`lobby/inject.js` `applyFit()` rotates `<html>`:

```
transform: translate(winW/z px, 0) rotate(90deg) scale(s)
transform-origin: 0 0
```

- `s` = `FIT` (0.86), the scale of the rotated lobby onto the CRT.
- `z` = webFrame zoom factor (1 by default).
- Window content bounds are `winW` × `winH` (larger × smaller, e.g. 641 × 480 on the CRT).
- Layout (CSS px) size of `<html>`: `layoutW = winH/(s·z)`, `layoutH = winW/(s·z)`.

Because Chromium multiplies every CSS px (including the translate) by the zoom, folding `z` into
both the layout size and the translate keeps the rotated content re-fit to the CRT at any zoom,
while the content still reflows (bigger text, less on screen) like normal zoom. At `z=1` the math is
identical to the un-zoomed fit (zero regression).

## Coordinate mapping (screen ↔ layout)

For overlays that must sit next to the pointer/element inside the rotated document:

```
screenX = winW/z − s·ly ;  screenY = s·lx
lx = clientY / s ;  ly = (winW/z − clientX) / s      // screenToLayout()
```

Fit vars refreshed by `applyFit`: `fitS = s`, `fitWinW = winW/z`, `fitLayoutW/H = layout size`.
Overlays are `position: fixed` inside `<html>` (which has the transform), so the transform is their
containing block and layout-px coordinates place them correctly on the physical CRT.

## Screen-space overlay pattern (reused 3×)

Anything Chromium/OS paints in screen space cannot be rotated by page CSS. Pattern: suppress the
native element and draw our own inside the rotated document.

| Native thing | Suppression | Replacement |
|--------------|-------------|-------------|
| `title` tooltip | strip `title` attr (+ MutationObserver) | `#fc-tate-tip` div, placed via `screenToLayout` |
| mouse cursor | `cursor: url(pre-rotated png)` in `inject.css` | rotated arrow bitmap |
| `<select>` popup | `mousedown` capture `preventDefault` | `#fc-tate-select` list; option click sets value + dispatches `input`+`change` so Vue `onChangeFilter()` runs |

The dropdown sizes to the full option list and nudges up to stay on screen (a pad cursor has no
scroll wheel), only falling back to a scrollbar if the list exceeds the whole column.

## Zoom controls + persistence

- `installZoomControls()`: `Ctrl` +/-/0 and `Ctrl`+wheel adjust `webFrame.setZoomFactor`, then
  `applyFit`. Menu `Zoom In/Out/Reset` routed through the same. A 200 ms watchdog re-fits (or clamps)
  when zoom drifts from the last fit — this catches the **native window menu** zoom, which changes
  webFrame zoom directly and bypasses the handlers.
- Persistence: `webFrame` zoom does reach Chromium's `Preferences`, but only on a debounced flush, so
  a value set right before ES kills the app is lost. Vertical mode therefore writes the factor to
  `/userdata/system/fightcade-flatpak/lobby-zoom-vertical` immediately on change and reads it on load.
  `fightcade-lobby-zoom` skips vertical entirely; landscape keeps the Preferences-based flow. The two
  are independent by construction (different storage), and `fightcade-lobby-zoom`'s mode key folds in
  `fcvertical` (`zoom_hd`, `zoom_hd_vertical`, `zoom_crt`, `zoom_crt_vertical`).

## Pad axis remap

The lobby is rotated 90° CW but X stays landscape, so the cursor delta is rotated to match:
`(dx, dy) → (−dy, dx)` in `fightcade-pad-mouse` `run_loop` when `lobby_vertical_enabled()`.

## FBNeo rotation persistence (CRT switchres)

`crt/fightcade-crt-switchres` backs up `fcadefbneo.ini` per game, patches resolution/aspect, and on
exit `restore_ini` does `mv backup → ini`. FBNeo writes the whole main ini on quit, so that restore
wiped in-game changes including `nVidRotationAdjust` (`Video > Rotate vertically aligned games`).
`restore_ini` now reads `nVidRotationAdjust` from the live ini and re-applies it after the restore,
so the switchres-managed keys revert but the user's rotation choice survives.
