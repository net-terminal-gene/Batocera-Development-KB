# Design — BUA Steam: Non-Steam Launcher Fixes

## Fix 1: Launcher Template (SteamLinuxRuntime chain)

### Current template (broken, lines ~403-435)

```bash
PROTON_PATH="${STEAM_APPS}/common/${proton_name}/proton"

if [ ! -d "$COMPAT_DATA/pfx" ]; then
  mkdir -p "$COMPAT_DATA"
  "$PROTON_PATH" run wineboot -u
fi

cd "${local_start_dir}" || exit 1
"$PROTON_PATH" run "${resolved_exe}" &
PID=$!
wait $PID
```

### Proposed template (validated)

```bash
SLR_ENTRY="${STEAM_APPS}/common/SteamLinuxRuntime_4/_v2-entry-point"
PROTON_PATH="${STEAM_APPS}/common/${proton_name}/proton"

export STEAM_COMPAT_DATA_PATH="$COMPAT_DATA"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="${STEAM_DIR}/.local/share/Steam"
export STEAM_COMPAT_APP_ID="${appid}"
export SteamAppId="${appid}"
export SteamGameId="${appid}"
export PULSE_SERVER="unix:/var/run/pulse/native"
export PROTON_NO_STEAM_OVERLAY=1
export WINEDLLOVERRIDES="lsteamclient=d;steam.exe=d"

if [ ! -d "$COMPAT_DATA/pfx" ]; then
  mkdir -p "$COMPAT_DATA"
  "$SLR_ENTRY" --verb=run -- "$PROTON_PATH" run wineboot -u
fi

cd "${local_start_dir}" || exit 1
"$SLR_ENTRY" --verb=run -- "$PROTON_PATH" run "${resolved_exe}" &
PID=$!
wait $PID
```

### Key differences

| Aspect | Old | New |
|--------|-----|-----|
| Launch wrapper | None (bare proton) | SteamLinuxRuntime_4/_v2-entry-point |
| Audio | Broken (no pulse routing) | Working (SLR container forwards socket) |
| Controllers | Broken (raw gamepad, inverted axes) | Working (SLR provides SDL environment) |
| Steam overlay | Assertion crash | Suppressed via env vars |

### Considerations

- `SteamLinuxRuntime_4` must be installed (it is automatically when Proton Experimental is installed)
- `_v2-entry-point` path is stable across Proton versions
- The `proton_name` variable (from `detect_proton()`) still determines which Proton version is used
- Official Steam game launchers (`-applaunch`) are unaffected — they don't use this template

## Fix 2: Artwork Dimension Fallback

### Current sgdb_get_image() (broken for many games)

```bash
sgdb_get_image() {
  local game_id="$1" key="$2" out_file="$3"
  resp=$(curl -sf -H "Authorization: Bearer $key" \
    "https://www.steamgriddb.com/api/v2/grids/game/${game_id}?dimensions=460x215&limit=1")
  # ... extract URL, download ...
}
```

### Proposed sgdb_get_image() (cascading fallback)

```bash
sgdb_get_image() {
  local game_id="$1" key="$2" out_file="$3"
  local dims="460x215 920x430"

  for dim in $dims ""; do
    local query="limit=1"
    [[ -n "$dim" ]] && query="dimensions=${dim}&${query}"
    local resp
    resp=$(curl -sf -H "Authorization: Bearer $key" \
      "https://www.steamgriddb.com/api/v2/grids/game/${game_id}?${query}" 2>/dev/null) || continue
    local url
    url=$(python3 -c "
import json, sys
try:
    d = json.loads(sys.argv[1])
    if d.get('success') and d['data']:
        print(d['data'][0]['url'])
except Exception:
    pass
" "$resp" 2>/dev/null)
    if [[ -n "$url" ]]; then
      curl -sf -L "$url" -o "$out_file" 2>/dev/null && return 0
    fi
  done
  return 1
}
```

Last iteration (empty `$dim`) queries with no dimension filter, accepting any available grid image.
