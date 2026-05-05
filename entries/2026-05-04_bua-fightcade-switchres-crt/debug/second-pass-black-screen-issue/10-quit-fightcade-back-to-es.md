# 10 — Quit Fightcade back to EmulationStation

**Context:** User **closed Fightcade** and returned to **EmulationStation** only (checklist **step 5** round-trip: ES → Fightcade → … → **quit Fightcade**).

**Compare:** **[01-baseline-after-reboot-pre-fightcade.md](01-baseline-after-reboot-pre-fightcade.md)** (cold ES baseline).

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

**Window count: 1**

```text
0x00c0000b  0 BATOCERA EmulationStation
```

Fightcade / FBNeo windows **gone**.

### Processes (`pgrep`)

**`fc2-electron`:** none (only **`bash -c`** from the probe).

**`switchres_fightcade_wrap.sh`:** none.

**`fcadefbneo`:** none.

### Wrapper post-switchres delay (on device)

```text
332:    sleep 4
```

### `fightcade.log` (`tail -45`)

Ends with **`sym_wine`** / Fightcade launcher teardown:

```text
fc2-electron is running.
...
fc2-electron is not running. Exiting script.
Script exiting. Symlink will be removed.
Removing symlink: /usr/bin/wine
```

---

## Summary

| Metric | Value |
|--------|--------|
| **currentMode** | `641x480.60.00` |
| **Active xrandr** | **`641x480` 60.00*** (progressive) |
| **Windows** | **1** (ES only) |
| **Fightcade stack** | **Not** running |

**Round-trip:** Raster matches **01** (**641×480 progressive**). **`SR-1_384x224@59.60`** remains in **xrandr** mode list, **not** active.

---

## Next

Relaunch **Fightcade** from Ports and run **TEST GAME** again for **ES → Fightcade → TEST GAME** black-screen retest (**11**), or **`fightcade-switchres.disable`** control per checklist **step 6**.
