# Second pass — Fightcade TEST GAME black screen (step-by-step)

**Status:** START HERE after reboot. Work **one step at a time**. Record each step in new numbered files in **this** folder (e.g. `01-baseline-after-reboot.md`).

**Rule:** Do not parallelize. Confirm picture + logs before advancing.

---

## Mandatory bundle for every entry

**From here on, every** numbered note in **this** folder **must** include verbatim SSH output (or one explicit **Blocking** line if capture was impossible, with reason). Narrative-only entries are **not** allowed.

Capture **at the moment** you describe in the note’s title (or state clearly if the snapshot is **belated** and why, like **`04`**).

Use **`export DISPLAY=:0.0`** on the SSH session for X queries.

| Block | Commands (verbatim paste into the markdown file) |
|--------|--------------------------------------------------|
| **Context** | One line: user-visible state (e.g. “ES only”, “Fightcade UI”, “SFIII room pre–TEST GAME”, “FBNeo running minimized”). |
| **`batocera-resolution`** | `batocera-resolution currentMode`, `currentResolution`, `getDisplayMode` |
| **`xrandr`** | Full output (not truncated unless insanely long; then state truncation). |
| **X sockets** | `ls -la /tmp/.X11-unix/` |
| **Windows** | `wmctrl -l` — always state **window count** in prose under the block. |
| **Processes** | At minimum: `pgrep -af switchres_fightcade`; `pgrep -af fcadefbneo` (or note none); `pgrep -af fc2-electron` (first few lines enough if spammy). Add Wine line if present. |
| **Wrapper delay** | `grep -n sleep .../switchres_fightcade_wrap.sh \| tail -1` **or** `sed -n '328,336p'` around post-switchres **`sleep`** when debugging timing. |
| **`fightcade.log`** | `tail -40` (or enough lines to show relevant Switchres/errors). |
| **Optional when relevant** | `tail -40 /userdata/system/logs/es_launch_stderr.log`; `test -f .../fightcade-switchres.disable`; `bash -n` on wrapper after edits. |

If SSH is unavailable, write **`### Mandatory bundle`** with **`Blocked: <reason>`** and do **not** merge the note until capture is filled.

---

## Preconditions

- [ ] Batocera rebooted (clean X, single **`/tmp/.X11-unix/X0`** unless intentionally otherwise).
- [ ] SSH to box works (`batocera.local` or IP).
- [ ] Know **`DISPLAY`** (`:0.0` typical).

---

## Step checklist (fill in as you go)

### 1 — Cold baseline

- [ ] From ES: note **`batocera-resolution currentMode`**, **`currentResolution`**, **`getDisplayMode`**.
- [ ] **`xrandr \| head -25`** saved to step note.
- [ ] Open Fightcade only (no TEST GAME). Screenshot or log window title / visible UI.

### 2 — First TEST GAME only

- [ ] Click TEST GAME **once**. Wait full post-switchres delay (wrapper **`sleep`** in current template).
- [ ] If black: **do not** reboot yet — SSH **`xrandr`**, **`ps aux`** (Fightcade, wrapper, wine, FBNeo), tail **`/userdata/system/logs/fightcade.log`**.
- [ ] Record whether **`switchres_fightcade_wrap.sh`** is running and **`fcadefbneo.exe`** exists.

### 3 — Exit and snapshot

- [ ] Exit emulator cleanly if possible.
- [ ] Capture **`PRE_*` equivalent**: **`currentMode`**, **`currentResolution`**, **`xrandr` current line**.

### 4 — Second TEST GAME (in session)

- [ ] Repeat TEST GAME **without** quitting Fightcade.
- [ ] Same SSH captures if black.

### 5 — ES round-trip (only after 4 stable or intentionally testing this bug)

- [ ] Quit Fightcade to ES.
- [ ] Relaunch Fightcade from Ports.
- [ ] TEST GAME again. Capture same logs if black.

### 6 — Switchres bypass control

- [ ] With **`touch /userdata/system/configs/fightcade-switchres.disable`**, repeat step 2.
- [ ] If picture returns while Switchres is off, root cause isolates to **Switchres / timing / modeline** path vs Wine/UI alone.
- [ ] **`rm`** disable file when done.

---

## Logs and files to scour every time

| Source | Why |
|--------|-----|
| `/userdata/system/logs/fightcade.log` | Fightcade shell, Switchres lines, wrapper errors |
| `/userdata/system/logs/es_launch_stderr.log` | ES launcher / X errors |
| `display.log` if present under `/userdata/system/logs/` | Batocera resolution script traces |
| `pgrep -af switchres_fightcade` | Wrapper stuck? |
| `pgrep -af 'fcadefbneo|fc2-electron|wine'` | Who is alive |
| `xrandr` | Current WxH vs menu vs SR |
| Wrapper on disk | **`bash -n`** after any edit |

---

## Output expectation

Each step gets its own **`NN-short-slug.md`** in **this** folder. Every file satisfies **[Mandatory bundle](#mandatory-bundle-for-every-entry)** above: **verbatim** command output (redact passwords), plus any narrative only **after** those blocks.

---

## Parent index

See **`../README.md`** for folder layout (`first-pass-*` archive vs `second-pass-*` active).
