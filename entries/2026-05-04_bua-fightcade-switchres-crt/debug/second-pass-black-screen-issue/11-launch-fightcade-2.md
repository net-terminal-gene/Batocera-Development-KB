# 11 — Launch Fightcade #2 (after ES round-trip)

**Context:** After **[10-quit-fightcade-back-to-es.md](10-quit-fightcade-back-to-es.md)** (ES only, **641×480 progressive**), user opened **Fightcade from Ports** again. **No TEST GAME** yet. Idle Fightcade UI.

**Compare:** **[02-fightcade-ui-only.md](02-fightcade-ui-only.md)** (first Fightcade open same session day).

---

## Mandatory bundle

Host **`batocera.local`**. **`export DISPLAY=:0.0`** for X queries.

### `batocera-resolution`

```text
641x480.59.98
641x480
xorg
```

### `xrandr`

```text
Screen 0: minimum 320 x 200, current 641 x 480, maximum 16384 x 16384
DP-1 connected primary 641x480+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98*+
   641x480       60.00  
  SR-1_384x224@59.60 (0x3d1)  7.841MHz -HSync -VSync
        h: width   384 start  415 end  452 total  506 skew    0 clock  15.50KHz
        v: height  224 start  234 end  237 total  260           clock  59.60Hz
```

### `/tmp/.X11-unix/`

```text
srwxrwxrwx 1 root root 0 May  4 17:27 X0
```

### `wmctrl -l`

**Window count: 2**

```text
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
```

### Processes (`pgrep`)

**`switchres_fightcade_wrap.sh`:** none (idle UI).

**`fc2-electron`:** new PID tree (**21001** …).

```text
21001 /userdata/system/add-ons/fightcade/Fightcade/fc2-electron/fc2-electron --no-sandbox
21003 .../fc2-electron --type=zygote --no-zygote-sandbox --no-sandbox
21004 .../fc2-electron --type=zygote --no-sandbox
21032 .../fc2-electron --type=gpu-process ...
21036 .../fc2-electron --type=utility ...
21047 .../fc2-electron --type=renderer ...
```

**`sym_wine.sh`:** **`20988`** (Wine symlink monitor).

### Wrapper post-switchres delay (on device)

```text
332:    sleep 4
```

### `fightcade.log` (`tail -40`)

Prior session teardown (**fc2-electron is not running**, symlink removed), then **Launching Fightcade** at **05:39:18**, symlink recreated, **`fc2-electron is running`**.

---

## Summary

| Metric | **[10](10-quit-fightcade-back-to-es.md)** (ES only) | **11** (Fightcade UI) |
|--------|------------------------------------------------------|------------------------|
| **currentMode** | `641x480.60.00` | **`641x480.59.98`** |
| **Active xrandr** | `641x480` **60.00*** | **`641x480i` 59.98*** |
| **Windows** | 1 | **2** |

Opening Fightcade again flips menu raster from **progressive** to **interlaced** **641×480**, matching **02** behavior.

---

## Next

Join room / **TEST GAME** when ready (**12**).
