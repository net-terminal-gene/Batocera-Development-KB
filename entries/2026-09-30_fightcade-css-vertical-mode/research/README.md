# Research — Fightcade Flatpak CSS Vertical (TATE) Lobby Mode

## Fightcade web bundle (minified Vue, scoped `[data-v-*]`)

- Room view: `.channelContent` contains `<chat>` (root `.chatWrapper`) and `<users-list>` (root
  `.usersListToolbar`). Chat has `.chatContent`, `.chatInput`, `.matchesWrapper`, `motd-message`
  (the "News"/RULES banner — it is the top of chat, not a separate panel). Members:
  `.usersListWrapper` > `.usersOnlineList` > `.userItem`.
- Culprit for the members panel covering the screen:
  `.usersListWrapper { position:fixed; top:60px; bottom:0; width:320px }`. Override to
  `position:static; width:100%`.
- Search view: `.searchWrapper > .contentWrapper > header > .inputWrapper` containing
  `input.text-filter` and `.filtersButton > svg.filtersButtonIcon`. Stock:
  `input.text-filter { min-width:400px; width:50% }`, `.inputWrapper { padding-left:40px }` — these
  overflow the portrait width and clip the filter button. Filters are native
  `<select class="selectValue">` (Genre/System/Ranked/Year) with `on change → onChangeFilter()`.

## Rotation / zoom math

- Fit: `translate(winW/z,0) rotate(90) scale(s)`, `s = FIT = 0.86`, `layoutW = winH/(s·z)`,
  `layoutH = winW/(s·z)`. Verified: at `z=1` identical to prior working fit.
- Chromium zoom LEVEL ↔ FACTOR: `factor = 1.2^level`. Observed `Preferences` value
  `-2.80178401692393` = `log_1.2(0.6)` = factor **0.6** (exactly the `ZOOM_MIN` clamp), confirming
  `webFrame.setZoomFactor(0.6)` reached Preferences.

## Zoom persistence findings

- `fightcade-lobby-zoom` reads/writes Chromium `Preferences`
  `partition.per_host_zoom_levels[<partition-id>]["web.fightcade.com"]` and mirrors it to
  `/userdata/system/configs/fightcade-lobby-zoom.conf` (`zoom_hd`/`zoom_crt`, LEVELS) at
  gameStop `save` / gameStart `apply`. Hooks wired in `fightcade-game-hook` (apply line ~182,
  save line ~157).
- **Bug:** log showed `saved crt_vertical zoom level -2.80178…` while the user had just zoomed *in* —
  the live "large" value never reached `Preferences` before the process was killed (debounced flush).
  Hence the file-based instant-write approach for vertical.
- `/userdata/system/fightcade-flatpak` is writable from the flatpak sandbox (used for the zoom file);
  confirmed the file updates live on each zoom change and survives exit.

## FBNeo config

- Main: `/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/config/fcadefbneo/fcadefbneo.ini`.
  `nVidRotationAdjust` (comment: "If non-zero, do not rotate the graphics for vertical games") holds
  the `Video > Rotate vertically aligned games` toggle. Per-ROM `games/<rom>.ini` only stores
  inputs/macros — rotation is global in the main ini.
- switchres `patch_wine_ini` changes resolution/aspect/stretch/window keys and makes
  `fcadefbneo.ini.bak.switchres`; `restore_ini` `mv`s it back on exit. Diff of live vs backup during a
  session shows only res/aspect/stretch differing — so preserving `nVidRotationAdjust` across the
  restore is safe and sufficient.
