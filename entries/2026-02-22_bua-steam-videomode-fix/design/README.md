# Design — BUA Steam VIDEO MODE Fix

## Architecture: How Configgen Loads Per-Game Settings

```
emulatorlauncher -system STEAM -rom game.sh
        │
        ▼
Emulator.py: settings = get_all(f'steam["game.sh"]')
        │
        ▼
batocera.conf: steam["2772080_Crystal_Breaker.sh"].videomode=854x480...
        │
        ▼
videoMode.changeMode(wantedGameMode)  ← only called if videomode key exists
        │
        ▼
batocera-resolution setMode 854x480...
```

**Critical:** The `-system` argument must match the key prefix in batocera.conf. `-system ports` → `ports["game.sh"]`; `-system steam` → `steam["game.sh"]`.

## Emulator Selection Flow

1. **es_systems** declares `<emulator name="sh">` for steam system
2. **batocera.conf** can override: `steam.emulator=sh` forces sh generator
3. **Generator choice:**
   - `steam` generator → runs `batocera-steam` (Flatpak)
   - `sh` generator → runs the .sh script content (BUA Launcher)

BUA Steam uses .sh launchers that call the BUA Launcher. The sh generator executes them. The steam generator expects Steam.steam / Flatpak.

## Data Flow: BUA Steam Install

```
steam2.sh (BUA UI) or steam.sh
        │
        ├── Downloads es_systems_steam.cfg → /userdata/system/configs/emulationstation/
        ├── Downloads es_features_steam.cfg → same
        └── Must write steam.emulator=sh, steam.core=sh → batocera.conf
```

**Note:** BUA UI uses `steam2.sh`; `steam.sh` has the fix. Ensure `steam2.sh` gets the same batocera.conf logic when PR merges.
