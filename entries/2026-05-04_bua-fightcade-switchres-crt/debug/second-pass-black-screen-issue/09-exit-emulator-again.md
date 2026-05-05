# 09 — Exit emulator again (after second TEST GAME + minimize)

**Context:** User exited FBNeo **again** after **[07-test-game-again.md](07-test-game-again.md)** (second launch) and **[08-minimize-window.md](08-minimize-window.md)** (minimize). Fightcade UI still open. Snapshot immediately after exit.

**Compare:** **[06-exit-emulator.md](06-exit-emulator.md)** (first exit after first TEST GAME).

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

### `wmctrl -l`

**Window count: 2**

```text
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
```

### Processes (`pgrep`)

**`switchres_fightcade_wrap.sh`:** none.

**`fcadefbneo`:** none.

**`fc2-electron`:** Fightcade shell still running (same pattern as **06**).

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

Heartbeats plus embedded **Switchres 384×224** / **duplicate mode** lines from **07** launch; tail ends **`fc2-electron is running`**.

---

## Summary

| Metric | **06** (first exit) | **09** (this capture) |
|--------|----------------------|------------------------|
| **currentMode** | `641x480.60.00` | **`641x480.60.00`** |
| **Active xrandr** | `641x480` **60.00*** | **`641x480` 60.00*** |
| **Windows** | 2 | **2** |
| **Wrapper / FBNeo** | Gone | **Gone** |

**Restore:** Second exit matches first: menu timing **641×480 progressive**, **`SR-1_384x224@59.60`** still listed but **not** starred.

---

## Next

**Checklist step 5:** quit Fightcade to ES, relaunch from Ports, TEST GAME for **ES round-trip** retest (**10**).
