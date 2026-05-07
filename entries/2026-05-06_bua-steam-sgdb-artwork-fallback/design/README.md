# Design — BUA Steam: SteamGridDB Artwork Fallback

## Architecture

Current flow in `create-steam-launchers.sh`:

```
shortcuts.vdf parsed → search_term derived → sgdb_search(term) → sgdb_get_image(game_id, key, out_file)
```

`sgdb_get_image()` calls:
```
GET /api/v2/grids/game/{id}?dimensions=460x215&limit=1
```

If `data[]` is empty (no images at that dimension), returns failure and no image is saved.

## Proposed Change

Replace single API call with cascading attempts:

```bash
sgdb_get_image() {
  local game_id="$1" key="$2" out_file="$3"
  local dims="460x215 920x430"
  
  for dim in $dims ""; do
    local query="limit=1"
    [[ -n "$dim" ]] && query="dimensions=${dim}&${query}"
    local resp
    resp=$(curl -sf -H "Authorization: Bearer $key" \
      "https://www.steamgriddb.com/api/v2/grids/game/${game_id}?${query}")
    local url
    url=$(python3 -c "..." "$resp")
    if [[ -n "$url" ]]; then
      curl -sf -L "$url" -o "$out_file" && return 0
    fi
  done
  return 1
}
```

Last iteration (empty `$dim`) queries with no dimension filter, accepting any available grid.
