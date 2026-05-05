# 07 — TEST GAME again (second launch, same Fightcade session)

**Context:** After **[06-exit-emulator.md](06-exit-emulator.md)** (menu **641×480** restored), user launched **TEST GAME** again without quitting Fightcade to ES. Capture taken **while emulator active** (wrapper waiting).

**Checklist mapping:** Step **4** “Second TEST GAME (in session)”.

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

Only **`:0`**.

### `wmctrl -l`

**Window count: 3**

```text
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
0x02400001  0 BATOCERA Fightcade FBNeo
```

(FBNeo title shorter than **05** snapshot; still SFIII rom **`sfiii3nr1`** in process line.)

### Processes (`pgrep`)

```text
16348 /bin/bash /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh fcade://play/fbneo/sfiii3nr1
16564 /bin/sh /userdata/system/add-ons/fightcade/Fightcade/emulator/../../Resources/wine.sh /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
16565 /tmp/.mount_wineOmhPDH/bin/bash /tmp/.mount_wineOmhPDH/wrapper /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
16567 /userdata/system/add-ons/fightcade/usr/bin/wine /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
16594 /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
5305 /userdata/system/add-ons/fightcade/Fightcade/fc2-electron/fc2-electron --no-sandbox
```

Wrapper **running** (`wait_for_emulators`). Wine mount path **`/tmp/.mount_wineOmhPDH/`** (new AppImage mount vs earlier session).

### Wrapper post-switchres delay (on device)

```text
332:    sleep 4
```

### `fightcade.log` (`tail -45`)

Ends with Switchres **384×224** modeline, **XRANDR duplicate mode** warning, **`wineserver`** / **`wine`** lines, then **`fc2-electron is running`**.

```text
Switchres: Calculating best video mode for 384x224@59.599491 orientation: normal
Switchres: Modeline "384x224_59 15.495868KHz 59.599491Hz" 7.840909 384 415 452 506 224 234 237 260   -hsync -vsync
XRANDR: <1> (add_mode) [WARNING] mode already exist (duplicate request)
...
wineserver: using server-side synchronization.
wine: Using setpriority to control niceness in the [-19,19] range
fc2-electron is running.
```

---

## Summary

| Metric | Value |
|--------|--------|
| **currentMode** | `384x224.59.60` |
| **xrandr active** | **`SR-1_384x224@59.60`*** |
| **Windows** | **3** |
| **Wrapper** | **Running** (`fcade://play/fbneo/sfiii3nr1`) |
| **Rom** | **`sfiii3nr1`** |

**Compared to first in-session run:** Geometry matches **[05](05-double-click-minimized-pre-exit.md)** (**384×224**). Second launch re-used expected Switchres path; **`fightcade.log`** shows duplicate-mode warning again.

**Visual outcome** (black vs picture): **not** recorded at SSH time; add a one-line user note if this pass differed from the first TEST GAME.

---

## Next

Exit emulator again for **`08`** if continuing the sequence, or quit Fightcade to ES for **round-trip** (**checklist step 5**).
