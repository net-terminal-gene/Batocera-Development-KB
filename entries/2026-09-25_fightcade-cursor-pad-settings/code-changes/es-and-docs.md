# code-changes — ES features + docs

## 2026-09-26 — Hide VERTICAL MODE toggle (keep logic)

`emulationstation/es_features_fightcade.cfg`: the `VERTICAL MODE` (`fcvertical`) `<feature>`
block is wrapped in an XML comment so it no longer appears in Advanced Game Options.
Vertical/TATE support was deprioritized vs Steam Deck work. **All `fcvertical` logic in
the hooks/scripts is left intact**; only the UI toggle is hidden. Re-enable by
uncommenting the block.

- Local + remote XML validated (`ET.parse` OK).
- Deployed to `/userdata/system/configs/emulationstation/es_features_fightcade.cfg`.
- ES only re-reads on restart, so the toggle stays visible until EmulationStation reloads
  (not restarted mid-session).

## 2026-09-26 — Flycast + Steam Deck external controller (docs only)

Symptom (user report): on Steam Deck, an external controller assigned to **P1's
CONTROLLER** in ES does not drive the Flycast menu; you end up using the Deck's built-in
controller. Workaround: assign ports inside Flycast once.

- `docs/CONTROLS.md`: added a NOTE after the Flycast/Dojo paragraph with the steps
  (Test Mode → touchscreen **Settings → Controls** → external pad to **Port A**, Deck pad
  to another port → tap bottom-left button in the left Settings nav bar to apply).
- `README.md`: added a Troubleshooting row pointing to that section.

**Open question:** does the Flycast port assignment persist across launches, or must it
be redone each Test Mode session? Doc currently says "assign once"; confirm during the
fresh-reinstall test and correct wording if it resets.

## 2026-09-26 — uninstall.sh 100% removal (commit fae951f)

Audited `uninstall.sh` vs `install.sh` + live device. Old uninstall left artifacts:

- `batocera.conf` keys `flatpak["Fightcade.flatpak"].*` (videomode, fclobby_*, fccursor_*, fcdebug, fcvertical) — never removed.
- ES recovery node `configs/emulationstation/recovery/flatpak/Fightcade.xml`.
- Orphan labwc `rc.xml.bak.fightcade-cursor` (from older cursor versions).
- Transient `/tmp/fightcade-*`, `/tmp/pad-mouse.log`.

Fix (added to `uninstall.sh`): `sed` delete of Fightcade batocera.conf lines (other
flatpak keys preserved, dry-run verified), rm recovery XML + empty dir, rm labwc backup,
sweep `/tmp`. **Verified on Steam Deck**: ran patched uninstaller, full re-scan returned
CLEAN for every artifact class (app, app-data, symlinks 2126+100, project dir, hook,
configs, es_features, recovery, batocera.conf, labwc backup, /tmp, gamelist).

## Branch / commits

Branch `feat/steamdeck-hd-fixes` on `net-terminal-gene/batocera-fightcade-flatpak`:
- `e2a5e87` — Deck HD cursor fixes, ES cursor-speed sliders, lobby vertical, hide toggle, docs.
- `fae951f` — uninstall 100% removal.

Install test command: `curl -fsSL .../main/install.sh | bash -s -- -y --branch feat/steamdeck-hd-fixes`.
