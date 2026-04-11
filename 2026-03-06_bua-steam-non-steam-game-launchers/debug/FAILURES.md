# Launch Failures — Non-Steam Game (Maldita Castilla)

Consolidated log of all failed launch attempts. Test game: Maldita Castilla, Shortcut ID: 3755861458.

---

## 1. steam://rungameid/ (single invocation)

| Attempt | Command | Result |
|---------|---------|--------|
| 1a | `steam -gamepadui -silent steam://rungameid/3755861458` | Steam Big Picture opens. Game does not launch. |
| 1b | `steam steam://rungameid/3755861458` (no -gamepadui) | Steam Desktop opens. Game does not launch. |

**Steam console log:** `Startup - Steam Client launched with: ... 'steam://rungameid/3755861458'`

---

## 2. -applaunch (matches real Steam game format)

| Attempt | Command | Result |
|---------|---------|--------|
| 2a | `steam -gamepadui -silent -applaunch 3755861458` | Steam Big Picture opens. Game does not launch. Launcher stuck on `wait $STEAM_PID`. |

**Steam console log:** `Startup - Steam Client launched with: ... '-applaunch' '3755861458'`

**Reference:** Street Fighter 6 (AppID 1364780) uses identical pattern and works: `steam -gamepadui -silent -applaunch 1364780`.

---

## 3. Signed / negative shortcut ID

| Attempt | Command | Result |
|---------|---------|--------|
| 3a | `steam -gamepadui steam://rungameid/-539106838` | Big Picture opens. Game does not launch. |

**Note:** -539106838 is the signed 32-bit representation of 3755861458. Tried in case Steam expects signed format.

---

## 4. Two-phase launch (start Steam, then send URL)

| Attempt | Command / flow | Result |
|---------|----------------|--------|
| 4a | 1) `steam -gamepadui -silent &`<br>2) Wait for Steam ready<br>3) `steam steam://rungameid/3755861458` | Stuck. Game does not launch. Second invocation may forward to running Steam; game still does not start. |
| 4b | 1) `steam -gamepadui -silent &`<br>2) Wait for Steam ready<br>3) `xdg-open steam://rungameid/3755861458` | Stuck. Game does not launch. xdg-open sends URL to system handler; Steam receives but does not launch game. |

**Launcher behavior:** Script does `wait $STEAM_PID`; Steam process tree stays alive; `wait` never returns. ES shows "launching" indefinitely. User must `pkill -f steam` to return.

---

## 5. Visibility / discovery failures

| Attempt | Setup | Result |
|---------|-------|--------|
| 5a | `Maldita Castilla.steam` containing `steam://rungameid/3755861458` | ES does not show the game. |
| 5b | `3755861458_Maldita_Castilla.sh` (bash launcher) | ES shows the game. |

**Cause:** `batocera.conf` has `steam.emulator=sh` and `steam.core=sh`. ES only discovers `.sh` files; `.steam` files are ignored.

---

## 6. Path / filesystem issues (resolved or ruled out)

| Issue | Detail | Resolution |
|-------|--------|------------|
| 6a | shortcuts.vdf stores Exe as `/root/MalditaCastilla/Maldita Castilla.exe` | On host, `/root/MalditaCastilla` did not exist. Game at `/userdata/system/add-ons/steam/MalditaCastilla/`. |
| 6b | Steam bwrap sandbox | Sandbox uses `--bind-try /userdata/system/add-ons/steam /root`. Inside sandbox, `/root` = steam addon dir. Path resolves correctly. Symlink on host not required. |
| 6c | Steam file browser | Could not browse `/userdata` (mergerFS). Symlink showed as 47-byte file. Had to copy game into `/userdata/system/add-ons/steam/MalditaCastilla`. |

---

## 7. Stuck state (recurring)

| Symptom | Cause |
|---------|-------|
| ES "launching" indefinitely | Launcher does `wait $STEAM_PID`. Steam process tree stays alive (Big Picture UI). `wait` never returns. |
| Cannot return to ES | User must run `pkill -f steam` (or use hotkey+start if padtokey configured). |
| Reboot sometimes needed | Leftover processes after `pkill` may require reboot. |

---

## 8. What works (baseline)

| Action | Result |
|--------|--------|
| Launch game from Big Picture library (manual) | Game runs. Proton Experimental, path, exe all correct. |
| Real Steam game from ES (e.g. Street Fighter 6) | `steam -gamepadui -silent -applaunch 1364780` → game launches. |
| Manual `.sh` launcher in ES | Game appears in list; launch triggers script; Steam opens; game does not start. |

---

## Summary

- **Steam receives** both `steam://rungameid/3755861458` and `-applaunch 3755861458`.
- **Big Picture opens** in all cases.
- **Game executable never starts** from CLI/URL launch.
- **Possible causes:** (a) `-applaunch` does not support shortcut IDs, (b) `steam://rungameid/` does not trigger launch for non-Steam shortcuts, (c) Proton/compat layer not invoked for shortcut path, (d) unknown Steam client behavior for shortcut IDs.
- **Upstream reference:** [ValveSoftware/steam-for-linux#9194](https://github.com/ValveSoftware/steam-for-linux/issues/9194) — `steam://rungameid` on non-Steam game with arguments caused segfault (fixed). Follow-up: "feature doesn't seem to be entirely functional" for non-Steam with custom args.

---

## 9. Proton direct launch — "Nothing" (2026-03-07)

### What the user sees

- User selects Maldita Castilla in ES and launches.
- **Nothing.** No game window, no Steam, no Proton splash. ES returns to game list (or briefly shows "launching" then back).

### ES launch log

```
ERROR (emulatorlauncher.py:587):runCommand /bin/bash: /userdata/roms/steam/3755861458_Maldita_Castilla.sh: No such file or directory
```

### Root cause

- **gamelist.xml** references `./3755861458_Maldita_Castilla.sh`.
- That file was removed when we deployed the Proton launcher with shortcut ID **3755550162** (matching live `shortcuts.vdf` and compatdata).
- Actual file on disk: `3755550162_Maldita_Castilla.sh`.
- ES passes the path from gamelist to bash → file not found → launch fails immediately.

### Process state (when "nothing" happens)

- `emulatorlauncher` runs with `-rom /userdata/roms/steam/3755861458_Maldita_Castilla.sh`
- `mergerfs-pin-internal.sh gameStart` / `gameStop` run
- No `3755861458_Maldita_Castilla.sh` process (script never executes)
- No Proton, no Steam, no game

### Fix applied

Symlink: `3755861458_Maldita_Castilla.sh -> 3755550162_Maldita_Castilla.sh` in `.roms_base/steam/`. ES follows symlink → Proton launcher runs → game launches.

---

## 10. Proton direct launch — SUCCESS (2026-03-07)

### What the user sees

- User selects Maldita Castilla in ES and launches.
- waveOut audio dialog appears (game-specific, not a Proton issue — dismiss with OK).
- **Game runs.** Confirmed working via VNC.

### What changed vs failures 1-8

- **No Steam CLI** — bypassed entirely. No `steam -applaunch`, no `steam://rungameid/`.
- **Proton direct** — `proton run "Maldita Castilla.exe"` with `STEAM_COMPAT_DATA_PATH` pointing at the existing compatdata prefix.
- **Correct shortcut ID** — 3755550162 (from Python parser), not 3755861458 (from manual hex extraction). The parser finds the correct `\x02appid\x00` marker.

### Remaining issue

- No hotkey exit until `.keys` file deployed. **Fixed:** `.sh.keys` added with `pkill -f steam; pkill -f proton`.
