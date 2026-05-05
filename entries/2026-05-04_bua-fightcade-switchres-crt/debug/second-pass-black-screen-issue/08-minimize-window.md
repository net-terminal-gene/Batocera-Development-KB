# 08 — Minimize game window (second pass, no exit)

**Context:** After **[07-test-game-again.md](07-test-game-again.md)** (second **TEST GAME** in session), user **double-clicked** to **minimize** the FBNeo / game window. **Emulator not** exited.

**Pairing:** Same intent as **[05-double-click-minimized-pre-exit.md](05-double-click-minimized-pre-exit.md)**, but on the **second** in-session run.

---

## Mandatory bundle

Host **`batocera.local`**. **`export DISPLAY=:0.0`** for X queries.

### `batocera-resolution`

```text
384x224.59.60
384x224
xorg
```

### `xrandr`

```text
Screen 0: minimum 320 x 200, current 384 x 224, maximum 16384 x 16384
DP-1 connected primary 384x224+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98 +
   641x480       60.00
   SR-1_384x224@59.60  59.60*
```

### `/tmp/.X11-unix/`

```text
srwxrwxrwx 1 root root 0 May  4 17:27 X0
```

### `wmctrl -l`

**Window count: 3**

```text
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
0x02400005  0 BATOCERA Fightcade FBNeo v0.2.97.44-55 • Street Fighter III 3rd Strike: Fight for the Future (Japan 990512, NO CD)
```

### Processes (`pgrep`)

Same **`switchres_fightcade_wrap.sh`** instance (**PID 16348**) as **07** (`fcade://play/fbneo/sfiii3nr1`). Emulator still running.

```text
16348 /bin/bash /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh fcade://play/fbneo/sfiii3nr1
16564 /bin/sh /userdata/system/add-ons/fightcade/Fightcade/emulator/../../Resources/wine.sh /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
16565 /tmp/.mount_wineOmhPDH/bin/bash /tmp/.mount_wineOmhPDH/wrapper /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
16567 /userdata/system/add-ons/fightcade/usr/bin/wine /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
16594 /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
5305 /userdata/system/add-ons/fightcade/Fightcade/fc2-electron/fc2-electron --no-sandbox
```

### Wrapper post-switchres delay (on device)

```text
332:    sleep 4
```

### `fightcade.log` (`tail -40`)

Mix of **`fc2-electron is running`**, then **Switchres 384×224** / **XRANDR duplicate** from **07** launch, **wineserver** / **wine** lines, more fc2 heartbeats. No new unique error at tail.

---

## Summary

| Metric | Value |
|--------|--------|
| **Mode** | `384x224.59.60`, **`SR-1_384x224@59.60`*** |
| **Windows** | **3** (FBNeo title long form again, like **05**) |
| **Wrapper** | **Still running** (same **PID 16348** as **07**) |
| **Minimize vs timing** | **No** change to **xrandr** current res (still **384×224** in-game) |

**Note:** `wmctrl` does not show minimized state; all three clients still appear in the list.

---

## Next

**Exit emulator** for another **`06`-style** restore check, or document **09** for that exit if numbering continues.
