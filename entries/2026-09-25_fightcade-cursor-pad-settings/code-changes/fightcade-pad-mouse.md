# code-changes — input/fightcade-pad-mouse

## 2026-09-26 — Restore cursor on SELECT+Start (Deck HD fullscreen → lobby)

New helper (always shows cursor, even on Wayland HD where `set_cursor_visible` is a no-op):

```python
def force_cursor_show(display: str) -> None:
    """Always re-enable the cursor, even on Wayland HD (ShowCursor does not warp).

    Used after SELECT+Start quits a fullscreen emulator: returning to the lobby
    must restore the pointer that the game hid.
    """
    if not os.path.isfile(CURSOR_CTL) or not os.access(CURSOR_CTL, os.X_OK):
        return
    env = os.environ.copy()
    env["DISPLAY"] = display
    try:
        subprocess.run(
            [CURSOR_CTL, "show"],
            env=env,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
            timeout=2,
        )
    except (OSError, subprocess.SubprocessError):
        pass
```

Both SELECT+Start / Alt+F4 branches now call it:

```python
                send_alt_f4(xdotool)
                last_alt_f4_at = now
                force_cursor_show(display)
                cursor_visible = True
                log("SELECT+Start sent Alt+F4 (cursor restored)")
```

(applied in the `wayland_hd_session()` branch and the `not wayland_hd_session()` legacy branch)

## Why safe

- `fightcade-cursor show` on Wayland = labwc `A-W-s` ShowCursor. Verified on hardware to **not** warp the pointer (only HideCursor `A-W-h` warps). So no risk of the old stutter/freeze loop.
- On X11 it kills the dedicated unclutter instance (existing behavior).

## Not committed

Local working-tree change in `net-terminal-gene/batocera-fightcade-flatpak`; deployed to device for testing. Commit/push only when the user asks.
