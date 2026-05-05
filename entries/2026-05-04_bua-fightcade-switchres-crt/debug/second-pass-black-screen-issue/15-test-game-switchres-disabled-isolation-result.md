# 15 — TEST GAME with `fightcade-switchres.disable` (isolation result)

**Preconditions:** **`/userdata/system/configs/fightcade-switchres.disable`** present (**[14](14-switchres-disable-isolation.md)**). Recovery from **`13`** black screen had been applied (**`minTomaxResolution`**). User ran **TEST GAME** on the round-trip path.

---

## User observation (authoritative)

**Quote:** “That looked like it **worked** but definitely **not Switchres looking**.”

**Reading:**

- **Worked:** Visible gameplay / acceptable picture with bypass enabled (contrast **`13`** black screen **with** Switchres).
- **Not Switchres looking:** Does **not** match native arcade raster (**384×224 @ ~15 kHz**) driven by **`switchres … -s -k`**. Expect scaling / staging inside **641×480** menu timing.

This matches wrapper behavior when **`fightcade_should_use_switchres`** fails: **`exec fcade.sh`** only (**no** Switchres, **no** Wine ini patch for SR geometry). See ```287:289:/Users/mikey/batocera-unofficial-addons/fightcade/switchres_fightcade_wrap.template.sh```.

---

## Interpretation vs **`13`**

| Condition | **`13`** (Switchres on, round-trip) | **`15`** (disable file, user report + SSH idle snapshot) |
|-----------|--------------------------------------|------------------------------------------------------------|
| **Picture** | Black (user) | **Works** (user) |
| **CRT staging** | Broken **`xrandr`** / missing FBNeo in **`wmctrl`** | Menu timing **641×480 progressive** in SSH capture; **FBNeo** listed in **`wmctrl`** |
| **Wrapper long path** | **`switchres_fightcade_wrap.sh`** ran Switchres | **`pgrep`** shows **no** wrapper when bypass **`exec`** replaces process (**below**: idle snapshot may differ if emu still open) |

**Conclusion for debugging:** The **round-trip black screen** is **strongly tied to the Switchres / wrapper / X mode path**, not “FBNeo never starts.” **Permanent fix** should repair that path; **`fightcade-switchres.disable`** is a **workaround**, not the CRT-native solution.

---

## Mandatory bundle (SSH snapshot after user confirmation)

**When:** Same investigation session; capture below may be **idle at Fightcade / post-game**, not mid-frame.

### Bypass flag

```text
disable_present
```

### `batocera-resolution`

```text
641x480.60.00
641x480
xorg
```

### `xrandr` (first 20 lines)

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

**Contrast `13`:** FBNeo **appears** in **`wmctrl`** here.

### Processes (`pgrep`)

**`switchres_fightcade_wrap.sh`:** none at capture (bypass **`exec`** path does not leave wrapper waiting).

**`fcadefbneo`:**

```text
29385 /bin/sh .../wine.sh .../fcadefbneo.exe sfiii3nr1
29388 .../wine .../fcadefbneo.exe sfiii3nr1
29413 .../fcadefbneo.exe sfiii3nr1
```

**`fc2-electron`:** **`21001`** tree.

### Wrapper post-switchres delay (on disk, unused when bypass)

```text
332:    sleep 4
```

### `fightcade.log` (`tail -35`)

Wine / **`fc2-electron`** heartbeats; **no** Switchres modeline lines in this tail.

---

## Related

- **`13-test-game-black-screen-bug-round-trip.md`**
- **`14-switchres-disable-isolation.md`**

## Cleanup when done with workaround

```bash
rm /userdata/system/configs/fightcade-switchres.disable
```

Expect **Switchres path** again (CRT-native timing **and** **`13`** risk until fixed).
