# Debug — Fightcade Vertical Library Genre Filter

## Verification commands

```bash
# After launching Fightcade, wait for login, then open Search → Genre → Vertical.
# Check the console log in the Fightcade developer tools or:
~/bin/ssh-batocera.sh 'cat /userdata/system/fightcade-flatpak/lobby/fc-vertical.log 2>/dev/null | tail -30'

# Expected log lines (page-world console.log only, not file-based in page world):
# [fc-vertical] ready
# [fc-vertical] genre-injected via __vue__.genres
# [fc-vertical] intercept idx=N page=0 filter=
# [fc-vertical] send all:true idx=N
# [fc-vertical] all-games idx=N total=FULL_COUNT got=FULL_COUNT
# [fc-vertical] filter src=FULL_COUNT matches=~200-700
```

## File checks on device

```bash
# Confirm files are in place
ls -la /userdata/system/fightcade-flatpak/lobby/vertical-*.js

# Confirm inject.js has setupVerticalSearch
grep -c setupVerticalSearch \
  /userdata/saves/flatpak/binaries/app/com.fightcade.Fightcade/x86_64/stable/active/files/fightcade/Fightcade/fc2-electron/resources/app/inject/inject.js
# expect: 2

# Confirm allowlist id count
grep -c ": 1" /userdata/system/fightcade-flatpak/lobby/vertical-allowlist.js
# expect: 732
```

## Failure signs

| Symptom | Likely Cause |
|---------|--------------|
| Vertical not in Genre dropdown | `injectVerticalGenre()` poll not finding `.filterItem.genre select` — Search page not open yet, or Vue class changed |
| Vertical stuck at the bottom of Genre | Old `genres.push`. Current code inserts in sort order. Relaunch Fightcade. |
| Join returns 400 `too many requests` | Catalog dump is back on the lobby socket. See `2026-10-01-join-rate-limit.md`. |
| Join uses the short allowlist title | Lookup missed the gameid. Log line `join-lookup-miss`. |
| Vertical list empty | `__FC_VERTICAL_IDS` not set. Allowlist script not injected. |
| TATE tooltips/selects broken | Regression in inject.js from setupVerticalSearch() changes |

## Prior failure log (context)

The prior agent's session (`6ec8e057`) left `vertical-ws.js` (1480 lines, version 8) and
`vertical-hook-min.js` (70 lines) as untracked files on the device. Those files were never
committed. They were superseded by the current clean rewrite and are orphans on the device.
