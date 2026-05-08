# PR Status — BUA Steam: Non-Steam Launcher Fixes

## Branch: `fix/steam-non-steam-launcher-slr`

Repo: `batocera-unofficial-addons`

### Changes ready (not yet PR'd)

Both fixes implemented in `steam/extra/create-steam-launchers2.sh`:

1. **Launcher template** — SteamLinuxRuntime + Proton Experimental chain with full env vars (sound, controller, assertion suppression)
2. **Artwork fallback** — Cascading dimension requests in `sgdb_get_image()` (460x215 -> 920x430 -> any)
3. **Removed `detect_proton()`** — Hardcoded Proton Experimental as default
4. **Removed `SDL_GAMECONTROLLERCONFIG`** — SLR provides proper SDL environment natively

### Next steps

- [ ] Deploy from branch to device for final validation
- [ ] Open PR against `batocera-unofficial-addons` main
 