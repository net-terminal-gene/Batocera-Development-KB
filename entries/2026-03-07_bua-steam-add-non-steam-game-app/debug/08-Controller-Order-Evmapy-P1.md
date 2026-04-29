# 08 — Controller Order, evmapy P1, and Steam Deck Disappearing

## Major Finding (User Report)

**Setup**: Steam Deck set to Player 1, external controller plugged in.

**In game**:
- Steam Deck controller did **not** work in the game
- External controller **did** work in the game
- Hotkey+Start did **not** exit (user was pressing it on the external controller)

**After SSH kill** (pkill proton/steam, killall evmapy/emulationstation):
- External controller worked in ES
- **Steam Deck controller disappeared** — not even in the controller assign list
- Had to assign external controller to P1 to use ES

## Root Cause

1. **evmapy only listens to Player 1** — emulatorlauncher passes `-p1devicepath` (Steam Deck when it's P1). evmapy grabs that device for Hotkey+Start and pass-through. evmapy does **not** listen to P2 (external controller).

2. **Hotkey+Start must be on P1** — If you press Hotkey+Start on the external controller (P2), evmapy never sees it. Only the P1 device triggers the exit.

3. **Game input**: evmapy grabs P1 (Steam Deck). The game may receive:
   - evmapy's virtual device (P1 pass-through) — game might not recognize it
   - External controller (P2) — **ungrabbed**, game gets it directly. Works.

4. **Steam Deck disappearing**: After force-killing evmapy/steam/emulationstation, the Steam Deck controller can drop out of the input device list. Likely a driver/udev state issue. **Reboot** typically restores it.

## Workaround

**Before launching a Non-Steam game**: Set the controller you'll **play with** as Player 1 in ES (Controller Settings → configure order). Then:
- evmapy listens to that controller for Hotkey+Start
- The game gets input from that controller (via evmapy or directly)

If you use an external controller for the game, make it P1 before launch. Hotkey+Start will then work from that controller.

## Steam Deck Not Recognized in Game

When Steam Deck is P1, evmapy grabs it. The game may not recognize evmapy's virtual device. Using an external controller (as P2) works because it's not grabbed — the game sees it directly. SDL_GAMECONTROLLERCONFIG and Proton Experimental may help when Steam Deck is the only controller.

## Restore Steam Deck After It Disappears

**First try** — use the force-exit script (ordered kills + udev trigger):

```bash
~/bin/ssh-batocera.sh "/userdata/system/add-ons/steam/extra/force-exit-non-steam-game.sh"
```

**If Steam Deck still missing** — reboot:

```bash
~/bin/ssh-batocera.sh "reboot"
```

If reboot is not possible, try replugging or power-cycling the Steam Deck. The controller may need a full reset.
