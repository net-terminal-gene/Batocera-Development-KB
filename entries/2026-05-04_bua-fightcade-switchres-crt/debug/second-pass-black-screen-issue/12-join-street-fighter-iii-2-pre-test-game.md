# 12 — Join Street Fighter III room #2 (pre–TEST GAME)

**Context:** After **[11-launch-fightcade-2.md](11-launch-fightcade-2.md)** (second Fightcade open post ES round-trip), user joined an **SFIII** room. **TEST GAME not** started.

**Compare:** **[03-sf3-room-pre-test-game.md](03-sf3-room-pre-test-game.md)** (first-pass SFIII room pre–TEST GAME).

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

**`switchres_fightcade_wrap.sh`:** none.

**`fcadefbneo`:** none.

**`fc2-electron`:** still **21001** tree from **11**.

```text
21001 /userdata/system/add-ons/fightcade/Fightcade/fc2-electron/fc2-electron --no-sandbox
21003 .../fc2-electron --type=zygote --no-zygote-sandbox --no-sandbox
21004 .../fc2-electron --type=zygote --no-sandbox
21032 .../fc2-electron --type=gpu-process ...
21036 .../fc2-electron --type=utility ...
21047 .../fc2-electron --type=renderer ...
```

### Wrapper post-switchres delay (on device)

```text
332:    sleep 4
```

### `fightcade.log` (`tail -45`)

Heartbeats from **11** launch (**05:39:18**); no Switchres game launch yet in this tail.

---

## Summary

| Metric | **[03](03-sf3-room-pre-test-game.md)** | **12** (this capture) |
|--------|----------------------------------------|-------------------------|
| **currentMode** | `641x480.59.98` | **`641x480.59.98`** |
| **xrandr active** | `641x480i` **59.98*** | **`641x480i` 59.98*** |
| **Windows** | 2 | **2** |
| **Wrapper / FBNeo** | Not running | **Not** running |

Second-pass SFIII room idle matches first-pass: **641×480 interlaced** Fightcade UI; wrapper appears only after **`fcade://`** game launch.

---

## Next

**TEST GAME** for round-trip retest (**13**).
