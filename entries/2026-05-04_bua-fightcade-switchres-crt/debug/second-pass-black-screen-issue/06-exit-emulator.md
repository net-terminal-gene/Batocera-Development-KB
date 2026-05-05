# 06 — Exit emulator (after SFIII / TEST GAME session)

**Context:** User **exited** the emulator (FBNeo). Fightcade UI still open. Capture immediately after exit.

**Compared to [05-double-click-minimized-pre-exit.md](05-double-click-minimized-pre-exit.md):** Display restored from **384×224** arcade mode to **641×480** menu timing. FBNeo window gone; **`switchres_fightcade_wrap.sh`** finished.

---

## Mandatory bundle

Host **`batocera.local`**. **`export DISPLAY=:0.0`** for X queries.

### `batocera-resolution`

```text
641x480.60.00
641x480
xorg
```

### `xrandr`

```text
Screen 0: minimum 320 x 200, current 641 x 480, maximum 16384 x 16384
DP-1 connected primary 641x480+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98 +
   641x480       60.00*
   SR-1_384x224@59.60  59.60
```

### `/tmp/.X11-unix/`

```text
srwxrwxrwx 1 root root 0 May  4 17:27 X0
```

Only **`:0`**.

### `wmctrl -l`

**Window count: 2**

```text
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
```

### Processes (`pgrep`)

**`switchres_fightcade_wrap.sh`:** none (wrapper exited).

**`fcadefbneo`:** none.

**`fc2-electron`:** still running (Fightcade shell). Representative lines:

```text
5305 /userdata/system/add-ons/fightcade/Fightcade/fc2-electron/fc2-electron --no-sandbox
5307 .../fc2-electron --type=zygote --no-zygote-sandbox --no-sandbox
5308 .../fc2-electron --type=zygote --no-sandbox
5348 .../fc2-electron --type=gpu-process ...
5352 .../fc2-electron --type=utility ...
5385 .../fc2-electron --type=renderer ...
```

### Wrapper post-switchres delay (on device)

```text
332:    sleep 4
```

### `fightcade.log` (`tail -45`)

Heartbeat **`fc2-electron is running`** lines only at capture (no Switchres errors in this tail).

---

## Summary

| Metric | Value |
|--------|--------|
| **currentMode** | `641x480.60.00` |
| **Active xrandr mode** | **`641x480` 60.00*** (progressive) |
| **Windows** | **2** (no FBNeo) |
| **Wrapper** | **Not** running |
| **384×224 Switchres mode** | Still **listed**, **not** active (`SR-1_384x224@59.60` without `*`) |

**Restore outcome:** Wrapper **`restore_display_mode`** path returned raster to **641×480 progressive**, aligned with **01** cold baseline (vs **02** Fightcade idle which had been **641x480i**).

---

## Next

Optional **07**: quit Fightcade to ES and repeat baseline, or **TEST GAME** again for round-trip black-screen retest per checklist step 5.
