# 13 — TEST GAME black screen bug (ES round-trip repro)

**User observation:** **Black screen** on **TEST GAME** after **12** (SFIII room #2), i.e. **second Fightcade session** after **10** (quit to ES) and **11** (relaunch) per round-trip checklist.

**Compare:** In first same-day session, **04 / 05 / 07** had picture; this pass reproduces the **ES → Fightcade #2 → room → TEST GAME** black-screen path.

---

## Mandatory bundle

Host **`batocera.local`**. **`export DISPLAY=:0.0`** for X queries.

### `batocera-resolution`

First SSH triple-command printed **`getDisplayMode`** only:

```text
xorg
```

Follow-up **`currentMode`** / **`currentResolution`** (with stderr): **no output** (empty).

### `xrandr`

**Anomaly:** `DP-1` line is **missing** the usual **`WIDTHxHEIGHT+…`** geometry; **no** `*` on any mode line in this paste (no explicit “active” mode).

```text
Screen 0: minimum 320 x 200, current 384 x 224, maximum 16384 x 16384
DP-1 connected primary (normal left inverted right x axis y axis)
   641x480i      59.98 +
   641x480       60.00
  SR-1_384x224@59.60 (0x3d1)  7.841MHz -HSync -VSync
        h: width   384 start  415 end  452 total  506 skew    0 clock  15.50KHz
        v: height  224 start  234 end  237 total  260           clock  59.60Hz
```

**`current` still reads 384×224** (in-game timing path).

### `/tmp/.X11-unix/`

```text
srwxrwxrwx 1 root root 0 May  4 17:27 X0
```

### `wmctrl -l`

**Window count: 2** — **no FBNeo client listed** (contrast **05 / 07 / 08** when FBNeo had a title bar).

```text
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
```

**`fcadefbneo.exe` is running** (see `pgrep`) but **not** in `wmctrl` at this capture. Possible off-screen, unmapped, or not yet created an X11 window the WM lists.

### Processes (`pgrep`)

```text
22164 /bin/bash /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh fcade://play/fbneo/sfiii3nr1
22276 /bin/sh /userdata/system/add-ons/fightcade/Fightcade/emulator/../../Resources/wine.sh /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
22277 /tmp/.mount_winecPpJmP/bin/bash /tmp/.mount_winecPpJmP/wrapper /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
22279 /userdata/system/add-ons/fightcade/usr/bin/wine /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
22307 /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
21001 /userdata/system/add-ons/fightcade/Fightcade/fc2-electron/fc2-electron --no-sandbox
```

Wrapper **waiting** on emulators. **Rom** **`sfiii3nr1`**. New Wine mount **`/tmp/.mount_winecPpJmP/`**.

### Wrapper post-switchres delay (on device)

```text
332:    sleep 4
```

### `fightcade.log` (`tail -80`)

Two **Switchres 384×224** blocks in the tail, each with **XRANDR duplicate mode** warning, then **wineserver** / **wine** lines, **fc2-electron** heartbeats. Second block corresponds to this **TEST GAME** launch.

```text
Switchres: Calculating best video mode for 384x224@59.599491 orientation: normal
Switchres: Modeline "384x224_59 15.495868KHz 59.599491Hz" 7.840909 384 415 452 506 224 234 237 260   -hsync -vsync
XRANDR: <1> (add_mode) [WARNING] mode already exist (duplicate request)
...
wineserver: using server-side synchronization.
wine: Using setpriority to control niceness in the [-19,19] range
```

---

## Summary (black screen + machine state)

| Signal | This capture |
|--------|----------------|
| **User picture** | **Black** (reported) |
| **X `current` size** | **384×224** (arcade path engaged) |
| **batocera-resolution** | **Mode / res** empty; **getDisplayMode** **xorg** only on first run |
| **FBNeo in `wmctrl`** | **Absent** while process **present** |
| **Switchres** | Same modeline + **duplicate** mode warning |

**Hypothesis (for follow-up, not proven):** Round-trip left X / WM / Wine in a state where **raster** is on **384×224** but **no visible FBNeo window** is registered, or output pipeline is wrong while processes stay up.

---

## Next

**Recovery:** exit emulator or **`minTomaxResolution` + `xrandr`** per prior notes; or **`fightcade-switchres.disable`** retest. Optional **14** after recovery snapshot.
