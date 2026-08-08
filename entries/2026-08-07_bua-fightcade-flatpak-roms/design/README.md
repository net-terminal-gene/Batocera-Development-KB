# Design — BUA Fightcade Flatpak — Missing ROMs Directory

## Delivery model

Same pattern as Sunshine Flatpak service install ([batocera-service-sunshine-flatpak](https://github.com/Redemp/batocera-service-sunshine-flatpak)):

- Hosted under [net-terminal-gene](https://github.com/net-terminal-gene) (proposed: `batocera-fightcade-flatpak`)
- One-shot `curl | bash` → `install.sh` on Batocera over SSH
- **No** Batocera systemd-style long-running service (Fightcade is launched from ES Ports)

## Architecture

```
install.sh
  ├─ assert Batocera + flatpak
  ├─ ensure Flathub
  ├─ flatpak install com.fightcade.Fightcade (if missing)
  ├─ batocera-flatpak-update
  ├─ mkdir ROMs scaffold under
  │    /userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/ROMs
  ├─ symlink Batocera /userdata/roms/* → Fightcade ROMs paths
  └─ flatpak override --system --filesystem=<each host path>
```

### Why arcade is special

```
ROMs/fbneo/                 ← real directory (not a symlink)
  ├── mslug3.zip → /userdata/roms/fbneo/mslug3.zip   (per-zip)
  ├── megadrive/ → /userdata/roms/megadrive          (dir)
  ├── nes/       → /userdata/roms/nes
  └── …
```

A single `ROMs/fbneo` → `roms/fbneo` link would hide console subdirs.

### Flycast / snes9x

Per-folder symlinks under real `ROMs/flycast/` and `ROMs/snes9x` → `roms/snes` (same pattern as manual PoC).

## Key paths

| Role | Path |
|------|------|
| Flatpak app id | `com.fightcade.Fightcade` |
| Persistent data | `/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/` |
| ROMs root | `.../data/ROMs` |
| Host ROM pool | `/userdata/roms/<system>` |
| Overrides (Batocera) | `/userdata/saves/flatpak/binaries/overrides/com.fightcade.Fightcade` |

## Out of scope

CRT, Switchres, BUA Wine/Electron Fightcade add-on, shipping ROM dumps, Dreamcast CHD hash hunting.
