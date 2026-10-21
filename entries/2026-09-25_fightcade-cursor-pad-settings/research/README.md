# Research — Cursor speeds, ES options, combos, platforms

Sources (repo `batocera-fightcade-flatpak`):

- `input/fightcade-pad-mouse.conf` — shipped defaults
- `/userdata/system/configs/fightcade-pad-mouse.conf` — user overrides (optional)
- `/tmp/fightcade-cursor-speed.conf` — runtime overlay from `fightcade-game-hook` at gameStart
- `emulationstation/es_features_fightcade.cfg` — Advanced Game Options
- `input/fightcade-pad-mouse` — daemon logic
- `input/fightcade-cursor` — X11 unclutter helper (not used on Deck HD)
- `fightcade-game-hook` — `sync_cursor_speed`, lobby chat sync

## How profile is chosen (HD vs CRT)

Pad-mouse picks **CRT** when either:

1. **Switchres CRT session** is active (`crt_switchres_active()` from `fightcade-crt-switchres`), or
2. **Display width &lt; 1024** (`crt_cursor_profile(display)`), matching sub-1024p CRT desktop.

Otherwise **HD** (1080p-style lobby and non-Switchres gameplay).

ES overlay mode for sliders uses `cursor_speed_profile` in the game hook (same hd/crt split at launch).

## Poll rate

Default **`poll_hz=60`** in code defaults (conf comment: pixels **per poll**, not per second). Movement per second ≈ `speed × poll_hz` at full deflection.

## Shipped speed defaults (`fightcade-pad-mouse.conf`)

| Key | Default | When used |
|-----|---------|-------------|
| `max_speed_hd` | 20 | HD: general lobby / gameplay cursor |
| `slow_speed_hd` | 3 | HD: R2 held (fine aim) |
| `max_speed_hd_menu` | 30 | HD: FBNeo/SNES in-emulator menu (SELECT+WEST pause path) |
| `slow_speed_hd_menu` | 5 | HD: menu + R2 |
| `max_speed_hd_lobby_drag` | 14 | HD: SOUTH held (drag-scroll lists/sidebars) |
| `slow_speed_hd_lobby_drag` | 2 | HD: drag-scroll + R2 |
| `max_speed_crt` | 6 | CRT: general (lower for sub-1024 desktop) |
| `slow_speed_crt` | 2 | CRT: R2 |
| `max_speed_crt_lobby` | 8 | CRT: lobby-only bump (no separate HD lobby max in conf; HD lobby uses `max_speed_hd`) |
| `slow_speed_crt_lobby` | 2 | CRT: lobby + R2 |
| `max_speed_crt_lobby_drag` | 5 | CRT: drag-scroll |
| `slow_speed_crt_lobby_drag` | 1 | CRT: drag-scroll + R2 |
| `max_speed_crt_menu` | 14 | CRT: emulator menu |
| `slow_speed_crt_menu` | 4 | CRT: menu + R2 |

Legacy keys `max_speed` / `slow_speed` in user conf map to **HD** only.

**Why CRT numbers are lower:** fewer pixels on screen; same stick deflection should not jump across the whole lobby. Menu speeds are higher than lobby on both profiles so FBNeo/SNES menus remain usable.

**Why separate lobby_drag:** holding SOUTH simulates click-drag; slower dedicated speeds avoid overshooting scroll areas.

## EmulationStation Advanced Game Options

File: `es_features_fightcade.cfg` (merged into ES from `/userdata/system/configs/emulationstation/`).

| Group | Feature | Key | Control | Effect |
|-------|---------|-----|---------|--------|
| FIGHTCADE | DEBUG LOGGING | `fcdebug` | switch | `/tmp/fightcade-debug.on`, verbose pad-mouse log, auto report on gameStop |
| FIGHTCADE | VERTICAL MODE | `fcvertical` | switch | Lobby rotation (TATE); separate from cursor |
| CURSOR SPEED | NORMAL | `fccursor_max` | slider 1–40, default 20 | At **gameStart**, writes overlay for active hd/crt: `max_speed_*`, `max_speed_*_lobby`, and on HD also `max_speed_hd_menu` |
| CURSOR SPEED | SLOWDOWN | `fccursor_slow` | slider 0.25–20, default 3 | Same overlay for `slow_speed_*`, `slow_speed_*_lobby`, HD `slow_speed_hd_menu` |
| EDIT LOBBY CHAT | NORTH/EAST/SOUTH/WEST/R2 | `fclobby_*` | input | Text sent when **R1 + face** in lobby (synced to conf before pad-mouse starts) |

**Important ES behavior:** settings save when the Advanced Game Options popup **closes**, not when LAUNCH is pressed inside it. User must close back to the game list, then launch Fightcade.

**CRT menu keys are never overwritten by ES sliders** — only HD menu keys get the slider overlay. CRT menu stays on conf defaults unless user edits conf.

Empty or invalid slider values → no overlay line; shipped conf defaults apply.

## Runtime overlay path

1. `gameStart` → `sync_cursor_speed()` in `fightcade-game-hook`
2. Writes `/tmp/fightcade-cursor-speed.conf` if sliders set
3. Pad-mouse loads user conf, then merges overlay
4. `gameStop` removes overlay

## Gamepad combos (pad-mouse)

Documented in script header; behavior in main loop.

| Combo | Action | Notes |
|-------|--------|-------|
| **SELECT + WEST** | FBNeo/SNES menu pause / CRT pause menu | Works CRT + HD |
| **SELECT + NORTH** | Resume from pause | CRT + HD |
| **SELECT + Start** | **Alt+F4** — quit emulator window back to lobby, **then force-show cursor** | PC: legacy chord detection. Deck HD: edge-based chord + `alt_f4_allowed()` guards. Since 2026-09-26 both branches call `force_cursor_show()` so the lobby cursor always returns (fixes hidden cursor after fullscreen). |
| **SELECT + R1** | Alt+Tab | Window focus shuffle |
| **R1 + NORTH/EAST/SOUTH/WEST/R2** | Send lobby chat macro | From per-game ES inputs → conf |
| **R2 alone** (while moving) | **Slow speed** | Uses `slow_speed_*` for current context |
| **SOUTH** (lobby) | Left click | Drag-scroll uses `*_lobby_drag` speeds while held |

Pad keyboard leaks (Alt+Enter, etc.) blocked by **`fightcade-crt-block-pad-kbd`** (separate script).

Flycast: SELECT+WEST/NORTH path also tied to menu cursor behavior (see pad-mouse Flycast branches).

## Platform matrix

| Environment | Session detect | Pointer move | Compositor cursor | `session.refresh()` |
|-------------|----------------|--------------|-------------------|---------------------|
| **PC HD / CRT (X11)** | not `wayland_hd_session()` | xdotool (integer px) | `fightcade-cursor` hide/show in gameplay/windowed paths | `_refresh_pc_legacy()` — original pgrep/xinput behavior |
| **Steam Deck HD (labwc)** | `is_wayland_session()` and not CRT Switchres | uinput relative motion; fractional stick on Deck | **No** hide/show (avoids warp loop) | `_refresh_deck_hd()` — cached emulator flags, throttled scans |
| **CRT Switchres** | CRT profile + switchres active | xdotool on X11 CRT box | CRT switchres wrapper owns timing | PC legacy refresh on X11 |

**`wayland_hd_session()`** definition: Wayland session **and** Switchres **not** active. All Deck-specific cursor fixes are gated here so **PC X11 CRT is unchanged**.

## Optional conf keys

- `deadzone` / `deadzone_8bit` — stick neutral zone
- `device_match` — substring to pick one gamepad

## Related toggles (not cursor speed)

- **`/userdata/system/fightcade-flatpak/fightcade-pad-mouse.disable`** — if present, hook does not start pad-mouse (cursor dead until removed)
- **`fightcade-lobby-zoom`** — Chromium zoom in Preferences at gameStart (mode-aware like CRT profile)

## What not to treat as current design

- Patching labwc `rc.xml` for cursor (rejected approach)
- Per-frame `wlrctl` warp to emu window on Deck (removed; caused stutter/freeze with uinput)
