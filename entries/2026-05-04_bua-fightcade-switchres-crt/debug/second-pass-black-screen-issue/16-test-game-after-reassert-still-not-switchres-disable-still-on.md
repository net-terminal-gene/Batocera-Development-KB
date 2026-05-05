# 16 — TEST GAME after reassert fix (“not Switchres looking”)

**User observation:** Ran **TEST GAME** after the **`fightcade_reassert_switchres_output`** wrapper update and it **still does not look like Switchres** (scaled / menu timing, not native arcade raster).

---

## Root cause for this run (confirmed over SSH)

**`/userdata/system/configs/fightcade-switchres.disable` is still present.**

When that file exists, **`fightcade_should_use_switchres`** returns false and the wrapper does **`exec fcade.sh`** immediately (**no** **`switchres -s -k`**, **no** **`fightcade_reassert_*`**, **no** ini patch path inside the Switchres branch). See ```287:289:/Users/mikey/batocera-unofficial-addons/fightcade/switchres_fightcade_wrap.template.sh```.

So this session **did not exercise** the new fix. Behavior matches **`15`** (bypass path).

---

## Mandatory bundle (SSH)

Host **`batocera.local`**. **`export DISPLAY=:0.0`** where noted.

### Bypass flag

```text
disable_STILL_PRESENT
```

### `batocera-resolution`

```text
641x480.60.00
641x480
xorg
```

### `xrandr` (first 18 lines)

```text
Screen 0: minimum 320 x 200, current 641 x 480, maximum 16384 x 16384
DP-1 connected primary 641x480+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98 +
   641x480       60.00*
  SR-1_384x224@59.60 (0x3d1)  7.841MHz -HSync -VSync
        h: width   384 start  415 end  452 total  506 skew    0 clock  15.50KHz
        v: height  224 start  234 end  237 total  260           clock  59.60Hz
```

**Active mode:** **`641x480` 60.00*** (menu progressive), **not** **`SR-1_384x224`***.

### `/tmp/.X11-unix/`

```text
srwxrwxrwx 1 root root 0 May  4 17:27 X0
```

### `wmctrl -l`

**Window count: 3**

```text
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
0x02400001  0 BATOCERA Fightcade FBNeo
```

### Processes (`pgrep`)

**`switchres_fightcade_wrap.sh`:** none (bypass **`exec`** replaces wrapper).

**`fcadefbneo`:**

```text
2840 /bin/sh .../wine.sh .../fcadefbneo.exe sfiii3nr1
2843 .../wine .../fcadefbneo.exe sfiii3nr1
```

### Wrapper on disk (contains reassert; unused while bypass active)

```text
265:fightcade_reassert_switchres_output() {
348:    fightcade_reassert_switchres_output "$W" "$H"
351:    fightcade_reassert_switchres_output "$W" "$H"
```

```text
350:    sleep 4
```

### `fightcade.log` (`tail -30`)

Wine / **`fc2-electron`** heartbeats; **no** Switchres modeline lines in tail.

---

## What to do to actually test the fix

1. **Remove bypass:**

```bash
rm /userdata/system/configs/fightcade-switchres.disable
```

2. Run **TEST GAME** again (expect **Switchres** staging and risk of **`13`** until fix is verified).

3. Log **`17`** with full bundle if testing the **full** Switchres path.

---

## Related

- **`15-test-game-switchres-disabled-isolation-result.md`**
- **Reassert fix** in **`switchres_fightcade_wrap.template.sh`** (`fightcade_reassert_switchres_output`).
