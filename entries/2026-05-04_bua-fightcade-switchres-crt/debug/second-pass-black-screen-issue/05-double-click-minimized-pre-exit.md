# 05 — Double-click minimize game window (no exit yet)

**When:** 2026-05-04 (SSH snapshot). User **double-clicked** (Fightcade / FBNeo) to **minimize** the game window. Emulator **not** exited.

---

## Display (major change vs menu **641×480**)

CRT is now at **native-resolution arcade timing**, not menu timing.

```text
$ export DISPLAY=:0.0
$ batocera-resolution currentMode
384x224.59.60

$ batocera-resolution currentResolution
384x224

$ batocera-resolution getDisplayMode
xorg
```

```text
$ xrandr
Screen 0: minimum 320 x 200, current 384 x 224, maximum 16384 x 16384
DP-1 connected primary 384x224+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98 +
   641x480       60.00
   SR-1_384x224@59.60  59.60*
```

**Active mode:** **`SR-1_384x224@59.60`** (**Switchres-added** mode name). Desktop geometry matches CPS3 (**384×224**).

---

## Windows (`wmctrl -l`)

**Count: 3**

```text
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
0x02400005  0 BATOCERA Fightcade FBNeo v0.2.97.44-55 • Street Fighter III 3rd Strike: Fight for the Future (Japan 990512, NO CD)
```

Minimize state may not show in `wmctrl -l` alone; FBNeo window still listed.

---

## Processes

| Component | Status |
|-----------|--------|
| **`fcadefbneo.exe`** | Running (**SFIII** rom id `sfiii3nr1` in command line) |
| **`switchres_fightcade_wrap.sh`** | **Still running** (`fcade://play/fbneo/sfiii3nr1`) |

**Why wrapper stays up:** Wrapper **`wait_for_emulators`** blocks until the emulator process exits. **Minimizing does not end** FBNeo, so the wrapper remains alive and has **not** run **`restore_display_mode`** yet.

Wine chain: **`wine.sh`** → **`fcadefbneo.exe sfiii3nr1`**.

---

## `fightcade.log` (tail)

Recent tail is **`fc2-electron is running`** heartbeat lines only at this capture.

---

## Summary

| Metric | Value |
|--------|--------|
| **currentMode / res** | **`384x224.59.60`** / **`384x224`** |
| **xrandr current** | **384×224**, mode **`SR-1_384x224@59.60`*** |
| **Openbox clients** | **3** (ES + Fightcade + FBNeo) |
| **Wrapper** | **Active** (blocked on emulator) |

---

## Next (checklist)

**Exit emulator** (or kill FBNeo) and capture again for restore behavior: **`06-post-emulator-exit-display.md`** with same **`batocera-resolution`**, **`xrandr`**, **`wmctrl`**, confirm **`switchres_fightcade_wrap`** exits and menu timing returns (**641×480** path).
