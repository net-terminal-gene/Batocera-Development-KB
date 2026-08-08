# Research — FBNeo Mega Drive for Flatpak Fightcade

**Compared:** 2026-08-07  
**Fightcade path:** `.../data/ROMs/fbneo/megadrive/*.zip`  
**Golden set:** NAS `/Volumes/Batocera/SETUP/fightcade/fbneo/megadrive` (not on `batocera.local` `/userdata`)  
**Batocera ES path:** `/userdata/roms/megadrive`

---

## Verdict

| Question | Answer |
|----------|--------|
| Can we symlink `/userdata/roms/megadrive` → Fightcade `fbneo/megadrive`? | **No** — wrong names and formats |
| Does SETUP have a Fightcade-ready Mega Drive set? | **Yes** — 1135 shortname `.zip`, ~1.7G |
| Best seed method on this host? | **Copy/rsync into** `ROMs/fbneo/megadrive` (already inside Flatpak data; no filesystem override needed) |

---

## Layout mismatch

| | Batocera `roms/megadrive` | Fightcade SETUP `fbneo/megadrive` |
|--|---------------------------|----------------------------------|
| Count (sample) | ~194 files | **1135** `.zip` |
| Extensions | mostly `.7z`, some `.zip`/`.bin` | **`.zip` only** |
| Names | long titles (`Alien Soldier.7z`) | FBNeo shortnames (`sonic2.zip`, `gunstar.zip`) |
| Zip contents | N/A / mixed | multi-region `.bin` dumps inside zip |

Example SETUP `gunstar.zip` members: `gunstar heroes (usa).bin`, `(jpn).bin`, `(euro).bin`, …

---

## Live Flatpak state (batocera.local)

- `ROMs/fbneo/` exists and is **empty** (no console subdirs yet).
- `fbneo_md_roms.json` in the app tree is a **broken symlink** → `/var/data/fbneo_md_roms.json` (file missing on host), same class of bug as early `flycast_roms.json`.
- Flatpak overrides today only cover flycast/snes/bios paths — **not** needed if megadrive zips live under `data/ROMs/fbneo/megadrive`.

---

## Source note (NAS vs Batocera disk)

Mac `/Volumes/Batocera` is SMB to **UGREEN NAS** (`DXP480TPLUS…/Batocera`), not `batocera.local:/userdata`.

So SETUP Fightcade trees are **not** already on the Fightcade machine. Seed = rsync from NAS share → Batocera:

```text
NAS: SETUP/fightcade/fbneo/megadrive/
  → batocera:/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/ROMs/fbneo/megadrive/
```

---

## Plan (megadrive only)

1. `mkdir -p .../ROMs/fbneo/megadrive`
2. Rsync SETUP megadrive zips into that dir (~1.7G)
3. Restore `fbneo_md_roms.json` into `.../data/` if Fightcade/frm still complains (source TBD — not shipped as a real file next to the symlink)
4. User QA: launch a known MD title in Flatpak Fightcade (e.g. `gunstar` / `sonic2`)

Arcade root (`ROMs/fbneo/*.zip`) and other console dirs are **out of this step**.
