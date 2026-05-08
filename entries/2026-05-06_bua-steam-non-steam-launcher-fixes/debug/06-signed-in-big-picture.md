# 06 — Signed In, Big Picture Mode Active

## Date: 2026-05-07

## Context

User logged into Steam. Big Picture Mode is active and functional.

## State

- **Steam ID:** 1080337349 (userdata directory created)
- **`steamapps/common/`:** Only `Steam Controller Configs` present (auto-downloaded on login)
- **No `shortcuts.vdf`** yet (no non-Steam games added)
- **No Proton Experimental** installed yet
- **No SteamLinuxRuntime_4** installed yet

## Next Steps (user action required)

1. Install **Proton Experimental** from Steam Library (free, under Tools)
2. SteamLinuxRuntime_4 will auto-install as a dependency
3. Switch to Desktop mode and add non-Steam game shortcuts
4. Exit Steam, then we rsync the patched script before next launch
