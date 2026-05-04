# Steam ↔ EmulationStation: `batocera-steam-update` path regression (v42 vs v43)

**Scope:** **x86_64** only (not Zen3) unless a separate capture says otherwise.  
**Status:** Documented from **live v42 SSH** + **v43 SSH snapshot (May 2026)** + **`batocera-linux` git** on disk. **Upstream fix:** [batocera-linux/batocera.linux#15670](https://github.com/batocera-linux/batocera.linux/pull/15670) **MERGED** 2026-05-04 to **`master`** (merge commit **`b27ce08ab38`**); dual-path **`Desktop`** + **`.../.local/share/applications`**. See KB **`pr-status.md`**.

---

## Executive summary

New Steam games not appearing in EmulationStation on **v43** is **not** “Flatpak Steam saving to the wrong place” and **not** a **`chmod`** issue on `gamelist.xml` or `.steam` stubs.

Batocera wires Steam into ES with **`/usr/bin/batocera-steam-update`**, which scans a **single directory** of `*.desktop` files and then writes **`/userdata/roms/steam/<Game>.steam`** plus calls ES’s **`addgames/steam`** API.

- **v42 (device under test, `42aco`):** the **installed** script still uses  
  **`/userdata/saves/flatpak/data/.var/app/com.valvesoftware.Steam/.local/share/applications`**  
  (verified with `sed -n '60,70p' /usr/bin/batocera-steam-update` over SSH).

- **v43 (earlier capture) + current `batocera.linux` tree:** the script uses  
  **`/userdata/saves/flatpak/data/Desktop/`**  
  while **`Desktop` was missing** on that v43 host and game shortcuts lived under **`.../applications/`** instead.

Upstream changed the scan path in commit **`ab1a8b85f913d126162492c9b2aa468f6dfb3122`** (2025-11-11, Modhack): *“fix: Flatpak Steam .desktop path”* — it **replaced** `applications` with **`Desktop/`**. If Flatpak Steam keeps writing game `.desktop` files under **`applications`**, **`batocera-steam-update` sees nothing** and no new ES entries appear.

---

## What `roms/steam/gamelist.xml` and `*.steam` files are

- **`gamelist.xml`:** ES metadata. Each game has `<path>./Game Name.steam</path>` (relative to the steam rom folder).
- **`<name>.steam`:** A **tiny text file** (one line is typical), e.g.  
  `steam://rungameid/1091500`  
  for Cyberpunk 2077 (observed on v42: `cat '/userdata/roms/steam/Cyberpunk 2077.steam'`).

These stubs **do not** store game saves; they only tell Batocera how to **launch** the title in Steam. Real installs and cloud/local state stay under **`/userdata/saves/flatpak/...`** (Steam’s Flatpak data).

---

## “It used to update when I installed in Steam” — what actually runs

Installing a game **inside the Steam client** does **not** by itself write new `*.steam` files or rewrite `gamelist.xml`.

The sync step is **`batocera-steam-update`**, which:

1. Ensures **`/userdata/roms/steam/Steam.steam`** exists (Flatpak app id).
2. **`find "$steam_apps_dir" -name '*.desktop'`** and filters **`Categories=...Game...`**.
3. For each new basename, writes **`/userdata/roms/steam/<basename>.steam`** with the `Exec=` line turned into a **`steam://...`** id.
4. **`curl`** to **`http://127.0.0.1:1234/addgames/steam`** with a small XML payload (ES must be running).

So the user-visible “refresh” is tied to **running that script**, commonly via **MAIN MENU → GAME SETTINGS → UPDATE GAMES LIST** for the Steam system.

### ES hook (build-time symlink)

From **`batocera.linux`** `package/batocera/utils/flatpak/flatpak.mk`:

```makefile
mkdir -p $(TARGET_DIR)/usr/share/emulationstation/hooks
ln -sf /usr/bin/batocera-flatpak-update \
    $(TARGET_DIR)/usr/share/emulationstation/hooks/preupdate-gamelists-flatpak
ln -sf /usr/bin/batocera-steam-update \
    $(TARGET_DIR)/usr/share/emulationstation/hooks/preupdate-gamelists-steam
```

On **v42 device**, symlinks present:

```text
preupdate-gamelists-steam -> /usr/bin/batocera-steam-update
```

So there is **no separate hidden daemon**: the **hook** + **`batocera-steam-update`** script are the integration.

---

## Upstream source today (`batocera-linux` repo path)

File: **`package/batocera/utils/batocera-steam/batocera-steam-update`**

Relevant lines (as in repo; **`Desktop/`**):

```bash
# Check if the Steam applications directory exists
steam_apps_dir="/userdata/saves/flatpak/data/Desktop/"

if [ ! -d "$steam_apps_dir" ]; then
    echo "Steam applications directory not found: $steam_apps_dir" >> $log
else
    find "$steam_apps_dir" -name "*.desktop" | (
    # ...
```

---

## Git: commit that changed the path

| Field | Value |
|--------|--------|
| **Commit** | `ab1a8b85f913d126162492c9b2aa468f6dfb3122` |
| **Author** | Modhack \<modhack@batocera.org\> |
| **Date** | Tue Nov 11 11:12:35 2025 +0100 |
| **Subject** | `fix: Flatpak Steam .desktop path` |

**Diff (only hunk):**

```diff
-steam_apps_dir="/userdata/saves/flatpak/data/.var/app/com.valvesoftware.Steam/.local/share/applications"
+steam_apps_dir="/userdata/saves/flatpak/data/Desktop/"
```

**Interpretation for upstream:** either Flatpak was changed so shortcuts land on **`Desktop`** (and **`applications`** was wrong), or the opposite on many installs — **evidence from v42 device + v43 capture suggests the move broke common layouts** where **`Desktop` is absent** and **`.desktop` files remain under `applications/`**.

---

## Evidence table (collected)

| Check | v42 x86_64 (SSH, 2026-05) | v43 x86_64 (SSH snapshot, 2026-05) | `batocera.linux` tree (local clone) |
|--------|---------------------------|-------------------------------------|--------------------------------------|
| **`batocera-version`** | `42aco 2025/10/06 14:36` | `43acou 2026/04/29 20:12` | — |
| **`steam_apps_dir` in `/usr/bin/batocera-steam-update`** | **`.../.local/share/applications`** | **`.../flatpak/data/Desktop/`** (live SSH + tree) | **`.../flatpak/data/Desktop/`** |
| **`/userdata/saves/flatpak/data/Desktop`** | **No such file or directory** | **Confirmed absent** (live SSH on `43acou`) | — |
| **Game `.desktop` location (example)** | (Steam uses `applications/`; v42 script reads same) | **`Blaze of Storm.desktop`**, **`Crystal Breaker.desktop`** in **`.../applications/`** (live SSH) | — |
| **ES hook** | `preupdate-gamelists-steam` → `batocera-steam-update` | (same design in image) | `flatpak.mk` installs hook |

**Note:** On **v42**, **`Desktop` is also missing**, but the **script points at `applications/`**, so **`find` still succeeds** and games can be added. That matches a populated **`roms/steam`** on v42.

---

## Live v43 re-confirmation (SSH, `batocera.local`)

After user returned the machine to **v43**, same checklist commands were run.

| Item | Result |
|------|--------|
| **`batocera-version`** | `43acou 2026/04/29 20:12` |
| **`/userdata/system/data.version`** | `43 2026/04/29 20:12` |
| **`steam_apps_dir` (lines 63–64 of `/usr/bin/batocera-steam-update`)** | **`/userdata/saves/flatpak/data/Desktop/`** |
| **`ls /userdata/saves/flatpak/data/Desktop`** | `No such file or directory` |
| **`ls .../applications \| head`** | `Blaze of Storm.desktop`, `Crystal Breaker.desktop`, … |

**Conclusion:** Script targets **`Desktop/`**, which **does not exist**; game shortcuts exist under **`applications/`**. Theory **confirmed** on this **v43 x86_64** image.

---

## chmod / permissions

Not indicated as root cause: **`batocera-steam-update`** creates **`644`**-style files as root; ES reads **`gamelist.xml`** from userdata. Failures observed align with **empty scan directory** (no new `.steam` files), not permission denied on existing metadata.

---

## Workarounds (until upstream fixes)

1. **One-time / per game:** Copy each game’s **`.desktop`** from  
   **`.../com.valvesoftware.Steam/.local/share/applications/`**  
   into **`/userdata/saves/flatpak/data/Desktop/`**, create **`Desktop`** if needed, then run **`batocera-steam-update`** with ES running.

2. **Script fix (upstream or overlay):** Scan **both** directories, or revert **`steam_apps_dir`** to **`applications`**, or document which Flatpak/Steam setting guarantees **`Desktop`** population.

3. **Persistent edit on Batocera:** If you patch **`/usr/bin/batocera-steam-update`** on the device, use **`batocera-save-overlay`** so it survives reboot (standard Batocera overlay workflow).

---

## Re-confirmation checklist (do this on **v43** before filing upstream)

1. `batocera-version` and `cat /userdata/system/data.version`
2. `sed -n '60,70p' /usr/bin/batocera-steam-update` → confirm **`steam_apps_dir=...`**
3. `ls -la /userdata/saves/flatpak/data/Desktop` and  
   `ls '/userdata/saves/flatpak/data/.var/app/com.valvesoftware.Steam/.local/share/applications' | head`
4. Install or pick one Steam game with a **`.desktop`** in **`applications`**, run **UPDATE GAMES LIST** (or `batocera-steam-update`), check **`tail -50 /userdata/system/logs/steam.log`**
5. ~~If **`Desktop` missing** and **`applications`** has game files but ES gets no new entries~~ **Confirmed on live v43** (see **Live v43 re-confirmation** above). Attach outputs + cite commit **`ab1a8b85f9`** when filing upstream.

---

## References (repo paths)

- **`batocera-linux`:** `package/batocera/utils/batocera-steam/batocera-steam-update`
- **`batocera-linux`:** `package/batocera/utils/flatpak/flatpak.mk` (ES hooks)
- **Commit:** `ab1a8b85f913d126162492c9b2aa468f6dfb3122`

---

## Related wiki (Batocera)

- Official: [systems:steam](https://wiki.batocera.org/systems:steam) (desktop shortcut / update gamelist guidance; troubleshooting mentions moving `.desktop` between locations).
