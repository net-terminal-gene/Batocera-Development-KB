# 07 — Exit Non-Steam Game (Hotkey+Start)

## Intended Behavior

Each Non-Steam game launcher gets a `.keys` file (e.g. `3672483792_Infinos2.sh.keys`) with:

```json
{
    "actions_player1": [
        {
            "trigger": ["hotkey", "start"],
            "type": "exec",
            "target": "pkill -f proton; pkill -f steam",
            "description": "Kill game / Proton"
        }
    ]
}
```

When you press **Hotkey+Start** during a game, evmapy runs that command. It should kill Proton and Steam, the game exits, the launcher script's `wait` returns, and you return to ES.

## Why Hotkey+Start May Not Work

| Cause | Explanation |
|-------|--------------|
| **Input grabbing** | Fullscreen Proton games can grab the input device exclusively. evmapy may not receive Hotkey+Start. |
| **Steam Deck hotkey** | On Steam Deck, "hotkey" is typically the "..." (Quick Access) button. Must be held while pressing Start. |
| **Wrong process names** | The game may run as `steam.exe` (wine) or the exe name. `pkill -f steam` matches "steam" in the command line; `pkill -f proton` matches proton. Both should work for Proton direct launch. |
| **evmapy device** | emulatorlauncher passes `-p1devicepath /dev/input/event17` (Steam Deck). If you use a different controller, evmapy might not be listening to it. |
| **.keys path** | evmapy looks for `{rom}.keys` next to the launcher. mergerfs: keys must exist in both `/userdata/.roms_base/steam/` and `/userdata/roms/steam/` for evmapy to find them. |

## Fallback: Force Exit via SSH

If Hotkey+Start doesn't work, run from Mac (uses same ordered script to avoid Steam Deck disappearing):

```bash
~/bin/ssh-batocera.sh "/userdata/system/add-ons/steam/extra/force-exit-non-steam-game.sh"
```

Or if the script doesn't exist:

```bash
~/bin/ssh-batocera.sh "killall evmapy; sleep 1; pkill -9 -f proton; pkill -9 -f steam; killall emulationstation"
```

ES will restart. Controllers should work (ordered kill + udev trigger helps Steam Deck reappear).

## Recommended Fix (Code)

Harden the `.keys` target to also restart ES, so you always get back to a working state:

```
pkill -9 -f proton; pkill -9 -f steam; killall evmapy; killall emulationstation
```

- `-9` = force kill
- `killall evmapy` = release input grab
- `killall emulationstation` = ES restarts (Batocera watchdog)

This matches the behavior of `steam.keys` for the main Steam system.
