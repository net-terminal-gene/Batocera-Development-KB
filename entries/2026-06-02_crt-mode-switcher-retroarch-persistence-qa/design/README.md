# Design — Mode Switcher RetroArch Persistence QA

## Architecture (current)

```text
CRT mode live:     /userdata/system/configs/retroarch/
                         │
         CRT→HD: backup_mode_files(crt) → mode_backups/crt_mode/emulator_configs/retroarch
                         │
         restore_mode_files(hd)  → replace live tree from hd_mode backup
                         │
HD mode live:      /userdata/system/configs/retroarch/   (may differ: overlays, empty remaps)
```

PR #438 ensures backup copies are not nested as `retroarch/retroarch/`.

## Architecture (proposed Phase B)

```text
Always on disk (both modes):
  config/remaps/          ← user controller profiles

Per-mode snapshots only:
  overlays/, config/<core>/ (CRT borders), cores/, inputs/, etc.
```

Requires explicit exclude list in `backup_mode_files` / `restore_mode_files`, and first-switch logic must not `rm -rf` shared paths.

## What Batocera regenerates each launch

| Path | Swapped by mode switch? | Survives if only playing a game? |
|------|-------------------------|----------------------------------|
| `retroarchcustom.cfg` | Yes | **No** — rewritten by configgen each libretro launch |
| `config/remaps/*.rmp` | Yes (today) | **Yes** — if saved from RA remap menu |
| `config/<Core>/*.cfg` | Yes | **Yes** — unless overwritten by script/install |
| `cores/retroarch-core-options.cfg` | Yes | **Yes** — core options file |
| `<system>.cfg` (e.g. `megadrive.cfg`) | Yes | **Yes** |
| `<system>/<rom>.cfg` | Yes | **Yes** |
| `/userdata/saves/` | No | N/A — not in swap tree |
