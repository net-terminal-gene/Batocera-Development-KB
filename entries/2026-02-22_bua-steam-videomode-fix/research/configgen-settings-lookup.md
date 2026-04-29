# Research: Configgen Settings Lookup

## How -system Affects Key Lookup

From batocera.linux configgen `Emulator.py` and `unixSettings.py`:

- `args.system` comes from emulatorlauncher's `-system` flag
- Per-game keys are: `{system}["{gsname}"]`
- `gsname` = ROM basename (e.g. `2772080_Crystal_Breaker.sh`)

**Example:**
- `-system steam` → looks up `steam["2772080_Crystal_Breaker.sh"].videomode`
- `-system ports` → looks up `ports["2772080_Crystal_Breaker.sh"].videomode`

BUA create-steam-launchers.sh writes per-game videomode to batocera.conf. The key format used by Batocera's UI is `steam["romname"]` when the system is "steam". So es_systems must use `-system steam` for configgen to find it.

## es_systems_steam.cfg Source of Truth

BUA ships this file to `/userdata/system/configs/emulationstation/es_systems_steam.cfg`. EmulationStation merges it with built-in systems. The `<command>` line is what emulatorlauncher receives — so `-system` and `-systemname` in that command control the config key namespace.
