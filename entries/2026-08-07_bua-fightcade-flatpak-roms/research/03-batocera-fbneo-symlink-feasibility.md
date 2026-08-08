# Research — Can `/userdata/roms/fbneo` symlink into Fightcade Flatpak ROMs?

**Compared:** 2026-08-07 via SSH `batocera.local`  
**Batocera path:** `/userdata/roms/fbneo`  
**Fightcade target:** `.../.var/app/com.fightcade.Fightcade/data/ROMs/fbneo`  
**Golden layout:** `/Volumes/Batocera/SETUP/fightcade/fbneo` (see `02-target-roms-layout.md`)

---

## Verdict

| Question | Answer |
|----------|--------|
| Does Batocera `roms/fbneo` match Fightcade **arcade root**? | **Yes** — flat shortname `.zip` + `neogeo.zip` |
| Does it match full Fightcade `fbneo/` (incl. consoles)? | **No** — missing all 12 console subdirs |
| Can we just symlink for arcade? | **Maybe** — structure fits; Flatpak sandbox must be allowed to see `/userdata/roms/fbneo` |
| Can we symlink Batocera console systems into Fightcade console dirs? | **No** — wrong layout and wrong file types |

---

## Side-by-side structure

| | Batocera `/userdata/roms/fbneo` | Fightcade SETUP `fbneo/` |
|--|--------------------------------|---------------------------|
| Shape | **Flat** (no subdirs) | Root arcade + **12 console dirs** |
| Arcade files | 2126 `.zip` | 2122 `.zip` at root |
| BIOS | `neogeo.zip` present | `neogeo.zip` at root |
| Extra files | `_info.txt`, `gamelist.xml` | none of those |
| Console subdirs | **none** | `coleco`, `gamegear`, `megadrive`, `msx`, `nes`, `nes_fds`, `pce`, `sg1000`, `sgx`, `sms`, `spectrum`, `tg16` |

Sample arcade titles present on Batocera: `mslug3.zip`, `dino.zip`, `kof98.zip`, `neogeo.zip`.

---

## What matches (arcade)

Fightcade FBNeo arcade expects:

```
ROMs/fbneo/<shortname>.zip
ROMs/fbneo/neogeo.zip
```

Batocera already is that (plus ES metadata). For **arcade-only** Fightcade, the folder content model matches.

`_info.txt` / `gamelist.xml` at the root are harmless noise for Fightcade (it ignores them).

---

## What does not match (consoles)

Fightcade wants e.g.:

```
ROMs/fbneo/megadrive/*.zip
ROMs/fbneo/nes/*.zip
```

Batocera keeps consoles elsewhere with **different names and formats**:

| Fightcade subdir | Batocera system path | Batocera formats (sample) |
|------------------|----------------------|---------------------------|
| `megadrive/` | `/userdata/roms/megadrive` | `.bin`, etc. — not Fightcade shortname zips |
| `nes/` | `/userdata/roms/nes` | `.nes`, etc. |
| `nes_fds/` | `/userdata/roms/fds` | different path name |
| `pce/` / `tg16/` | `/userdata/roms/pcengine` | different path name |
| `coleco/` | `/userdata/roms/colecovision` | different path name |
| `spectrum/` | `/userdata/roms/zxspectrum` | different path name |
| `sms/` / `msx/` | not present as those dir names on this host | — |

So: do **not** expect `ln -s /userdata/roms/megadrive .../fbneo/megadrive` to work for Fightcade.

---

## Symlink plan (arcade only)

Intended link (after ROMs root exists):

```bash
FC_FBNEO=/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/ROMs/fbneo
# prefer: replace empty dir with symlink to Batocera set
rmdir "$FC_FBNEO" 2>/dev/null || true
ln -s /userdata/roms/fbneo "$FC_FBNEO"
```

### Blocker: Flatpak sandbox

`com.fightcade.Fightcade` has **no** host filesystem override granting `/userdata/roms`. A symlink from sandbox `data/ROMs/fbneo` → `/userdata/roms/fbneo` will typically be **invisible/broken inside the sandbox** unless you add something like:

```bash
flatpak override --user --filesystem=/userdata/roms/fbneo com.fightcade.Fightcade
# on Batocera, overrides may need --system and persist under saves/flatpak
```

[Inference] Without that override (or a bind-mount into the flatpak data tree), symlink will look correct on the host and fail inside Fightcade.

### Safer alternative (no override)

Hard-link or copy is heavy. Bind-mount into the already-allowed data dir:

```bash
mkdir -p .../data/ROMs/fbneo
mount --bind /userdata/roms/fbneo .../data/ROMs/fbneo
```

(persist via fstab/custom service — more moving parts.)

---

## Recommendation

1. **Arcade:** Yes, treat Batocera `/userdata/roms/fbneo` as the Fightcade FBNeo arcade pool — structure matches.
2. **Symlink:** Try it **plus** a Flatpak filesystem override for `/userdata/roms/fbneo`; verify a known title (e.g. room TEST / challenge with `mslug3`) sees the ROM.
3. **Consoles:** Keep separate; populate Fightcade console dirs from SETUP (or Fightcade-named zips), not from Batocera `roms/<system>`.
4. **Flycast / snes9x:** out of this comparison (Flycast not in play; snes9x not checked here).
