# 12 — Desktop Mode: Proton Experimental Installed

## Date: 2026-05-07

## Context

User switched to Desktop mode inside Steam and installed Proton Experimental from the Library.

## State

- **Proton Experimental:** Installed (`proton` binary exists)
  - Path: `.../steamapps/common/Proton - Experimental/proton`
  - Manifest: `appmanifest_1493710.acf`
- **SteamLinuxRuntime_4:** NOT YET INSTALLED
  - No `SteamLinuxRuntime*` in `common/`
  - May still be downloading, or may need separate install
- **Generator:** Running (loop 65+), now seeing `Manifests processed: 1` (Proton)
- **No shortcuts.vdf** yet (non-Steam games not added)

## Note on SLR_4

SteamLinuxRuntime_4 (appid 2526340) does NOT auto-install as a Proton dependency. **User must manually install it by searching for "Steam Linux Runtime 4.0" in the Steam Library search bar.**

Same for Proton Experimental: search "Proton Experimental" in the Library search bar and install.

Without SLR_4, our generated launchers will fail (the pre-flight check will report "SteamLinuxRuntime_4 not installed").

## Final State

- **Proton Experimental:** Installed (manual from Library)
- **SteamLinuxRuntime_4:** Installed (manual from Library > Tools)
- Both confirmed present on filesystem with expected binaries

## Next Step

1. Verify SLR_4 appears (check again in a minute, or manually trigger from Library > Tools)
2. Add non-Steam game shortcuts
