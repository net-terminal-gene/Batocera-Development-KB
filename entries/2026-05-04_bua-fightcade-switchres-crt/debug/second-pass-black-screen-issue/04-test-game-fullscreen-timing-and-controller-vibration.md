# 04 — TEST GAME fullscreen: timing + controller vibration

**When:** 2026-05-04

---

## Capture gap (first draft)

The first version of this note recorded **timing** and **controller** observations only. It did **not** include the usual **`batocera-resolution` / `xrandr` / `wmctrl` / `pgrep`** blocks at the exact moment of the **first** TEST GAME fullscreen transition.

The **Supplementary SSH snapshot** below was taken **later the same day** while **SFIII was still running** (wrapper + FBNeo active). It matches **in-game geometry** (**384×224** Switchres mode), not the **641×480** Fightcade UI state from steps **02–03**. For a clock-accurate “first launch” sheet, re-run the same commands immediately after clicking TEST GAME on a future pass.

---

## Supplementary SSH snapshot (SFIII session active)

**Approximate context:** Game session open; same timeline as **05** (minimize experiment). Host **`batocera.local`**, **`DISPLAY=:0.0`**.

### `batocera-resolution`

```text
384x224.59.60
384x224
xorg
```

### `xrandr`

```text
Screen 0: minimum 320 x 200, current 384 x 224, maximum 16384 x 16384
DP-1 connected primary 384x224+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98 +
   641x480       60.00
   SR-1_384x224@59.60  59.60*
```

### `/tmp/.X11-unix/` (same capture)

```text
srwxrwxrwx 1 root root 0 May  4 17:27 X0
```

Only **`:0`** (no secondary X socket).

### `wmctrl -l` (window count **3**)

```text
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
0x02400005  0 BATOCERA Fightcade FBNeo v0.2.97.44-55 • Street Fighter III 3rd Strike: Fight for the Future (Japan 990512, NO CD)
```

### Processes (`pgrep`; verbatim lines trimmed to essentials)

```text
7515 /bin/bash /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh fcade://play/fbneo/sfiii3nr1
7764 /bin/sh /userdata/system/add-ons/fightcade/Fightcade/emulator/../../Resources/wine.sh /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
7767 /userdata/system/add-ons/fightcade/usr/bin/wine /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
7796 /userdata/system/add-ons/fightcade/Fightcade/emulator/fbneo/fcadefbneo.exe sfiii3nr1
5305 /userdata/system/add-ons/fightcade/Fightcade/fc2-electron/fc2-electron --no-sandbox
```

Wrapper **still running** during gameplay (`wait_for_emulators`). FBNeo process present.

### Wrapper post-switchres delay (on device)

```text
332:    sleep 4
```

### `fightcade.log` (tail)

Heartbeat **`fc2-electron is running`** lines only at capture (no Switchres errors in this tail).

---

## TEST GAME (Street Fighter III room)

**Observed:** Fullscreen TEST GAME felt like **~9 seconds** before gameplay was acceptable (user perception).

**Cause (confirmed):** On-device **`switchres_fightcade_wrap.sh`** had **`sleep 9`** immediately after **`switchres … -s -k`**. Repo template **`batocera-unofficial-addons/fightcade/switchres_fightcade_wrap.template.sh`** already specified **`sleep 4`** with a comment that **9s did not fix** black-on-launch; device had drifted to **9**.

**Fix applied (same day):** On **`batocera.local`**, line **332** edited back to **`sleep 4`**. Verified **`bash -n`** passes. Backup written as **`switchres_fightcade_wrap.sh.bak`** next to the wrapper on the device.

**Expectation:** Post-switchres settle delay returns to **4 seconds** unless other waits (Wine, emulator spawn) add wall-clock time on top.

---

## Controller: vibration driven by game audio

**Observed:** Controller was **vibrating in sync with game sound**, described as vibrating **the sound** rather than normal speaker output through TV or speakers. **Unplug and replug** the controller restored sane behavior.

**Note:** Logged as a **hardware / USB / audio routing** symptom during this CRT Switchres session. Root cause **not** isolated here (SDL, Wine hidraw, Fightcade path, or pad firmware).

**Workaround recorded:** Physical **disconnect / reconnect** of the gamepad.

**Extended write-up (hypotheses, why not CRT/Switchres):** **`19-controller-vibration-with-game-audio.md`**.

---

## Related

- **`19-controller-vibration-with-game-audio.md`** — documented why vibration can recur and what is inference vs observation.
- Prior discussion in **`debug/first-pass-black-screen-issue/README.md`**: 9s experiment did not resolve persistent black screen; UX cost was deemed too high.
- Wrapper post-switchres delay lives next to: **`/usr/bin/switchres "$W" "$H" "$R" -s -k`** then **`sleep N`** then **`"$FCADE_SH" "$URL"`**.
