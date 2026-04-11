# 05 — SSH Log Investigation (Cancel Does Not Return to ES)

**Date:** 2026-03-07  
**Method:** SSH via `~/bin/ssh-batocera.sh` — inspect logs on Batocera machine, document each step. No guessing.

---

## Step 1: List Log Locations

**Command:**
```bash
~/bin/ssh-batocera.sh "ls -la /userdata/system/logs/ 2>/dev/null; ls -la /var/log/ 2>/dev/null | head -30"
```

**Result:** Log directories exist.

| Location | Relevant Files |
|---------|----------------|
| `/userdata/system/logs/` | `es_launch_stderr.log`, `es_launch_stdout.log`, `game_START_and_STOP.log`, `display.log`, `steam.log` |
| `/var/log/` | `messages`, `Xorg.0.log` |

---

## Step 2: Read es_launch_stderr.log

**Command:**
```bash
~/bin/ssh-batocera.sh "cat /userdata/system/logs/es_launch_stderr.log"
```

**Content (verbatim):**
```
evmapy: no process found
2026-03-07 18:16:27,652 ERROR (emulatorlauncher.py:587):runCommand <frozen importlib._bootstrap>:488: RuntimeWarning: Your system is avx2 capable but pygame was not built with support for it. The performance of some of your blits could be adversely affected. Consider enabling compile time detection with environment variables like PYGAME_DETECT_AVX2=1 if you are compiling without cross compilation. The performance of some of your blits could be adversely affected. Consider enabling compile time detection with environment variables like PYGAME_DETECT_AVX2=1 if you are compiling without cross compilation.
```

**Findings:**
- `evmapy: no process found` — printed to stderr during the Add Non-Steam Games launch. Source not located in `/usr` grep (may be from a script or evmapy itself when it exits).
- Pygame AVX2 RuntimeWarning — harmless; pygame 2.6.1 reports compile-time option.

---

## Step 3: Read es_launch_stdout.log

**Command:**
```bash
~/bin/ssh-batocera.sh "tail -100 /userdata/system/logs/es_launch_stdout.log"
```

**Relevant sequence (timestamps):**

| Time | Event |
|------|-------|
| 18:16:22,339 | launch: Batocera 43-dev |
| 18:16:22,382 | start_rom: system=steam, emulator=sh, core=sh |
| 18:16:22,481–584 | gameStart scripts: nvidia-workaround, powermode_launch_hooks, rotation_fix, tdp_hooks, first_script, mergerfs-pin-internal, 1_GunCon2 |
| 18:16:22,587 | evmapy: merge keys from Add_Non-Steam_Games.sh.keys, steam.keys, hotkeys.keys |
| 18:16:22,593 | evmapy ready |
| 18:16:24,033 | runCommand: `/bin/bash /userdata/roms/steam/Add_Non-Steam_Games.sh` |
| 18:16:27,652 | **runCommand stdout:** pygame 2.6.1 (SDL 2.32.8, Python 3.12.8), "Hello from the pygame community" |
| 18:16:27,652 | hotkeygen: resetting to default context |
| 18:16:27,801 | gameStop: first_script.sh |
| 18:16:27,836 | gameStop: mergerfs-pin-internal.sh |
| 18:16:27,849 | gameStop: 1_GunCon2.sh |
| 18:16:27,863 | gameStop: nvidia-workaround.sh |
| 18:16:27,866 | gameStop: powermode_launch_hooks.sh (log truncated) |

**Finding:** The pygame process exited ~3.5 s after launch. `runCommand` returned (stdout captured). gameStop scripts ran. Emulatorlauncher completed its flow.

---

## Step 4: Read game_START_and_STOP.log

**Command:**
```bash
~/bin/ssh-batocera.sh "cat /userdata/system/logs/game_START_and_STOP.log"
```

**Content:**
```
===== 2026-03-07T18:16:22-07:00 | first_script.sh gameStart ... =====
...
===== 2026-03-07T18:16:27-07:00 | first_script.sh gameStop ... =====
2026-03-07T18:16:27-07:00 [gameStop] gameStop: Restoring EmulationStation Rotation + Resolution
2026-03-07T18:16:27-07:00 [gameStop] xrandr rotation emulationstation: normal
2026-03-07T18:16:27-07:00 [gameStop] xrandr display output: DP-1
2026-03-07T18:16:27-07:00 [gameStop] EmulationStation Resolution: 768x576
2026-03-07T18:16:27-07:00 [gameStop] Done.
```

**Finding:** gameStop ran and reported restoring ES rotation and resolution (768x576).

---

## Step 5: Inspect emulatorlauncher Flow

**Commands:**
```bash
~/bin/ssh-batocera.sh "sed -n '200,250p' /usr/lib/python3.12/site-packages/configgen/emulatorlauncher.py"
~/bin/ssh-batocera.sh "sed -n '560,610p' /usr/lib/python3.12/site-packages/configgen/emulatorlauncher.py"
```

**Flow (from source):**
1. `runCommand(cmd)` — `subprocess.Popen` + `proc.communicate()` blocks until child exits
2. Child exits → `communicate()` returns → `runCommand` returns exitCode
3. `callExternalScripts(USER_SCRIPTS, "gameStop", ...)`
4. `callExternalScripts(SYSTEM_SCRIPTS, "gameStop", ...)`
5. `finally`: restore resolution (`videoMode.changeMode_cvt`), restore mouse
6. `return exitCode` → emulatorlauncher exits

**Finding:** Emulatorlauncher waits for the child, runs gameStop, restores video/mouse, then exits. No extra wait on evmapy.

---

## Step 6: Deployed Launcher and .keys

**Commands:**
```bash
~/bin/ssh-batocera.sh "head -20 /userdata/roms/steam/Add_Non-Steam_Games.sh"
```

**Launcher content:**
```bash
#!/bin/bash
# Pygame UI — reads controller directly, no evmapy/focus issues
export HOME=/root
export DISPLAY=:0.0
python3 /userdata/system/add-ons/steam/extra/add-non-steam-game.py
```

**Add_Non-Steam_Games.sh.keys:** hotkey Start → `pkill -9 -f add-non-steam-game`; B/select → KEY_ESC; A/start → KEY_ENTER.

---

## Step 7: /var/log/messages (18:16)

**Relevant entries:**
- 18:16:22 evmapy[21335] initializing, loaded event16.json, handling 1 device
- 18:16:23 evmapy handling 1 device, batocera-mouse-reset
- 18:16:27 mergerfs garbage collection

No errors or crashes in messages around launch/exit.

---

## Summary: What the Logs Show

| Observation | Source |
|-------------|--------|
| Pygame app started | es_launch_stdout |
| Pygame app exited ~3.5 s later | es_launch_stdout (pygame banner, then gameStop) |
| gameStop scripts ran | es_launch_stdout, game_START_and_STOP |
| first_script restored ES resolution (768x576) | game_START_and_STOP |
| emulatorlauncher completed (runCommand returned, gameStop, finally) | emulatorlauncher.py flow |
| evmapy "no process found" on stderr | es_launch_stderr (origin not identified) |

---

## What the Logs Do NOT Show

- Whether ES actually redraws or regains focus after emulatorlauncher exits
- Whether the display remains in a bad state (blank, wrong mode)
- Whether ES is blocked by another process or X11 state
- Whether the user pressed Cancel (clean_exit) or Start (pkill -9)

---

## Next Steps (Evidence-Based)

1. **Reproduce with timestamp:** Run app, press Cancel, note exact time; then `tail` es_launch_stdout and game_START_and_STOP to confirm same pattern.
2. **Check ES process:** After "Nothing again", SSH and run `ps aux | grep -E 'emulationstation|EmulationStation'` — is ES running?
3. **Check X11 state:** After repro, `DISPLAY=:0 xdotool getactivewindow` and `wmctrl -l` — what window has focus?
4. **Compare with working app:** Launch another Steam system app (e.g. a game that exits cleanly), compare logs and behavior.

---

## Follow-up: first_script.sh and Display Restore (2026-03-07)

**Finding:** ES is running after Cancel (user confirmed via `ps aux`). The issue is ES not visible/focused, not ES crashed.

**first_script.sh gameStop** (on Batocera):
- Logs "EmulationStation Resolution: 768x576" but applies `xrandr --output DP-1 --mode "641x480"`
- Display supports: 769x576i, 641x480 (current)
- ES runs windowed at 641x480

**Fix applied:** Add explicit `xrandr -display :0.0 --output DP-1 --mode 641x480` to the launcher *after* the Python process exits, before the script returns. This forces the display into a known state immediately after pygame quits, before emulatorlauncher's gameStop runs. Deploy script updated.

**Result:** Same behavior — ES still not visible after Cancel. xrandr post-exit did not fix it. Display restore is not the root cause.
