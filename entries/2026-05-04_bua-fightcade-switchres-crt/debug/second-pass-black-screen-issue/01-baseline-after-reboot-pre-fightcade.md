# 01 — Baseline after reboot (pre–Fightcade)

**When:** 2026-05-04, ~17:28 local (SSH snapshot shortly after boot; ES idle at menu).

**Context:** Fresh reboot into EmulationStation. Fightcade **not** launched.

---

## Resolutions / video stack

**`DISPLAY=:0.0` required** for `batocera-resolution currentMode` / `currentResolution` over SSH. Without `DISPLAY`, commands print `Can't open display` (only `getDisplayMode` still surfaced `xorg` in one run).

```text
$ export DISPLAY=:0.0
$ batocera-resolution currentMode
641x480.60.00

$ batocera-resolution currentResolution
641x480

$ batocera-resolution getDisplayMode
xorg
```

**`xrandr` (abbreviated; full capture below):**

- Screen min/max: **320×200** … **16384×16384**
- **Current:** **641×480**
- **Output:** `DP-1` connected primary **641x480+0+0**
- Modes listed: **`641x480i` 59.98+**, **`641x480` 60.00*** (asterisk = current mode)

```text
Screen 0: minimum 320 x 200, current 641 x 480, maximum 16384 x 16384
DP-1 connected primary 641x480+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98 +
   641x480       60.00*
```

---

## X server sockets

```text
$ ls -la /tmp/.X11-unix/
srwxrwxrwx 1 root root 0 May  4 17:27 X0
```

Single display **`:0`** only (no stray `:1`).

---

## Windows open (Openbox)

**`wmctrl -l`:** **1** client window.

```text
0x00c0000b  0 BATOCERA EmulationStation
```

---

## Relevant processes (snippet)

```text
2351 openbox --config-file /etc/openbox/rc.xml --startup emulationstation-standalone
2354 /bin/bash /usr/bin/emulationstation-standalone
3338 dbus-run-session -- emulationstation --exit-on-reboot-required --windowed --screensize 641 480 --screenoffset 00 00
3343 emulationstation --exit-on-reboot-required --windowed --screensize 641 480 --screenoffset 00 00
```

---

## Uptime at capture

```text
17:28:06 up 0:01, load average: 0.63, 0.18, 0.06
```

---

## Optional extras for later steps (not captured here)

Use when comparing **after Fightcade / TEST GAME**:

| Item | Command / path |
|------|----------------|
| Full `xrandr` | `export DISPLAY=:0.0; xrandr` |
| Fightcade log tail | `tail -80 /userdata/system/logs/fightcade.log` |
| ES launcher stderr | `tail -80 /userdata/system/logs/es_launch_stderr.log` |
| Display script log | `ls -la /userdata/system/logs/display.log`; `tail` if present |
| Switchres wrapper running | `pgrep -af switchres_fightcade` |
| Wine / FBNeo | `pgrep -af 'fcadefbneo|fc2-electron|wine'` |
| Wrapper syntax | `bash -n /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh` |
| Bypass flag | `test -f /userdata/system/configs/fightcade-switchres.disable && echo disable_on` |

---

## Summary

| Metric | Value |
|--------|--------|
| **currentMode** | `641x480.60.00` |
| **currentResolution** | `641x480` |
| **getDisplayMode** | `xorg` |
| **xrandr current** | **641×480** on **DP-1** (progressive **60.00***) |
| **Openbox window count** | **1** (`BATOCERA EmulationStation`) |
| **X sockets** | **X0** only |
