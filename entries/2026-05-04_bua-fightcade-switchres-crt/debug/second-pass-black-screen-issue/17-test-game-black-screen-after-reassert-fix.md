# 17 — TEST GAME black screen again (Switchres on, after `fightcade_reassert` deploy)

**User observation:** **Black screen** on TEST GAME with **`fightcade-switchres.disable`** **removed** (renamed to **`fightcade-switchres.enable`**). Full Switchres path active; **`fightcade_reassert_switchres_output`** present on device.

**Compare:** **`13-test-game-black-screen-bug-round-trip.md`** (same fingerprint). **`15`** picture with bypass only.

---

## Mandatory bundle

Host **`batocera.local`**. **`export DISPLAY=:0.0`** for X queries.

### Bypass flag

```text
disable_off
```

(`fightcade-switchres.disable` absent; optional stub **`fightcade-switchres.enable`** may exist from rename.)

### `batocera-resolution`

```text
xorg
```

**`currentMode` / `currentResolution`:** empty (only **`getDisplayMode`** printed).

### `xrandr`

**Same class of fault as `13`:** **`current 384 x 224`** but **`DP-1 connected primary`** line **without** **`WIDTHxHEIGHT+…`** geometry; **no** `*` marking active mode in paste.

```text
Screen 0: minimum 320 x 200, current 384 x 224, maximum 16384 x 16384
DP-1 connected primary (normal left inverted right x axis y axis)
   641x480i      59.98 +
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

**Window count: 2** — **no FBNeo** title (matches **`13`**).

```text
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
```

### Processes (`pgrep`)

```text
5406 /bin/bash /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh fcade://play/fbneo/sfiii3nr1
5535 /bin/sh .../wine.sh .../fcadefbneo.exe sfiii3nr1
5538 .../wine .../fcadefbneo.exe sfiii3nr1
5565 .../fcadefbneo.exe sfiii3nr1
21001 .../fc2-electron/fc2-electron --no-sandbox
```

Wrapper **running**; emulator **running**; user **still** sees black.

### Deployed wrapper (reassert present)

```text
265:fightcade_reassert_switchres_output() {
348:    fightcade_reassert_switchres_output "$W" "$H"
351:    fightcade_reassert_switchres_output "$W" "$H"
350:    sleep 4
```

### `fightcade.log` (`tail -55`)

**Switchres** modeline + **`XRANDR ... duplicate request`**; Wine lines; **`fc2-electron`** heartbeats.

---

## Interpretation

**Post-`switchres` `xrandr --output … --mode SR-…`** did **not** stabilize RandR enough to restore a starred mode / sane **`DP-1`** line in this failure mode. Black screen repro **persists** with Switchres enabled.

**Next engineering angles** [Inference]: stronger pre-switchres **`minTomax`** when stale **`SR-`** modes exist; **`xrandr --delmode`** / refresh duplicate modes (risky); Wine fullscreen / FBNeo window mapping; or **`batocera-resolution setMode`** after Switchres instead of raw **`xrandr`**.

---

## Recovery

SSH: **`batocera-resolution minTomaxResolution`**, then **`xrandr`** to menu mode if needed; **`pkill`** emulator/wrapper if stuck. Same as prior recovery.

---

## Related

- **`13`**, **`16`** (disable rename), **`switchres_fightcade_wrap.template.sh`** (`fightcade_reassert_switchres_output`).
