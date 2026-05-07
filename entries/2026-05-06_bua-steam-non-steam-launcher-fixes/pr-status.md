# PR Status — BUA Steam: Non-Steam Launcher Fixes

## No PR yet

Two fixes to implement in `create-steam-launchers.sh`:

1. **Launcher template** — Replace bare `proton run` with SteamLinuxRuntime chain (validated on-device)
2. **Artwork fallback** — Cascade dimension requests in `sgdb_get_image()` (designed, not yet implemented)

PR will be opened against `batocera-unofficial-addons` once both fixes are implemented and tested.
