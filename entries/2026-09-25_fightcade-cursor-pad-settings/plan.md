# Fightcade Flatpak — Cursor and Pad Settings (PC CRT/HD + Steam Deck)

## Agent/Model Scope

Composer + local repo reads; Deck validation via `ssh-batocera` when updating debug section.

## Problem

Fightcade Flatpak pad navigation spans multiple config layers (shipped `fightcade-pad-mouse.conf`, per-user conf, ES sliders, `/tmp` overlay at launch). Combos differ slightly on Deck vs PC. Recent Deck-only fixes (`_refresh_deck_hd`, `wayland_hd_session()`) must stay isolated from CRT/X11 PC. There is no single user-facing doc explaining **every setting and why it exists**.

## Root Cause

N/A (documentation session, not a product bug).

## Solution

1. Document all cursor speed keys, when each applies (lobby / menu / drag / gameplay), and HD vs CRT detection.
2. Document ES Advanced Game Options (CURSOR SPEED, lobby chat, debug, vertical).
3. Document pad combos and which subsystems they trigger (pad-mouse vs `fightcade-crt-switchres`).
4. Document platform matrix: pointer backend (xdotool vs uinput), compositor cursor, refresh behavior.
5. Cross-link to debug notes on lobby pgrep stutter (historical footgun).

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-Development-KB | `entries/2026-09-25_fightcade-cursor-pad-settings/*` | New session |
| batocera-fightcade-flatpak | — | **No** public/user docs; KB + vault only |
| Vault-Batocera | active-work, development-contributions, batocera-development-kb, log, _hot | Sync |

## Validation

- [ ] Every `max_speed_*` / `slow_speed_*` key in shipped conf explained with apply context
- [ ] ES slider → overlay → pad-mouse path documented
- [ ] All documented combos match `input/fightcade-pad-mouse` header + code
- [ ] PC vs Deck differences explicit (`wayland_hd_session()`)
- [ ] VERDICT written when doc pass accepted by maintainer

## Fixes landed this session

- [x] 2026-09-26 Cursor restore on SELECT+Start (Deck HD) — `force_cursor_show()`, user-confirmed on hardware.
- [x] 2026-09-26 Hide VERTICAL MODE ES toggle (logic kept) — deployed; effective on next ES restart.
- [x] 2026-09-26 Docs: Flycast + Steam Deck external-controller port assignment (`docs/CONTROLS.md`, README row).
- [x] 2026-09-26 `uninstall.sh` 100% removal (batocera.conf keys, ES recovery, labwc backup, /tmp) — verified CLEAN on Deck. Branch `feat/steamdeck-hd-fixes` (`e2a5e87`, `fae951f`), pushed.

## Next test (later) — fresh reinstall on Steam Deck + PC

- [ ] Clean `curl | bash` install on **Steam Deck** and on **PC**; verify everything so far.
- [ ] SELECT+Start cursor restore (Deck HD, fullscreen → lobby).
- [ ] VERTICAL MODE toggle absent from Advanced Game Options after ES restart.
- [ ] Flycast external-controller Port A workaround; confirm whether assignment persists.
- [ ] Lobby + Test Mode cursor smooth (no stutter regression).
