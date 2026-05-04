# Design — v43 game saves layout

**Scope:** Layout below reflects **v43 x86_64**. Zen3 images may differ; label any future Zen3 snapshot separately.

## Architecture (high level)

```text
/userdata (persistent partition, typically ext4)
├── roms/          # game library (ROMs, ports, steam stubs, …)
├── saves/         # canonical “saves” tree (readme + per-emulator after play)
├── system/        # batocera.conf, configs/, logs/, …
├── bios/ …        # other userdata siblings
└── (optional) .roms_base  # mergerFS internal pin; absent when pool not used

Flatpak (incl. Steam) → large tree under /userdata/saves/flatpak/
```

## Flow

- **Libretro / standalone:** configgen writes emulator configs at launch; in-game saves usually land under `/userdata/saves/<system-or-core>/` (populated after games are played).
- **Steam (flatpak):** Steam library + cloud/local state live under `saves/flatpak/data/.var/app/com.valvesoftware.Steam/...` (not under `roms/` except `.steam` launch stubs).

## Open questions (for v42 compare)

- Does v42 use the same `saves/flatpak` split and size profile?
- With **mergerFS**, does `.roms_base` change where **saves** or **flatpak** live?
