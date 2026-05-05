# Debug — Fightcade Switchres

Work is split into passes:

| Folder | Role |
|--------|------|
| **[first-pass-black-screen-issue/](first-pass-black-screen-issue/)** | **Archived** first investigation: all former **`01`–`07`** notes + **[README.md](first-pass-black-screen-issue/README.md)** with full chronology of moves |
| **[second-pass-black-screen-issue/](second-pass-black-screen-issue/)** | **Resolved** second pass: `--rmmode` fix confirmed — **[README.md](second-pass-black-screen-issue/README.md)** |
| **[emulator-test/](emulator-test/)** | **Active** multi-emulator validation: fbneo, ggpofba, snes9x, flycast — **[README.md](emulator-test/README.md)** |

New checkpoints go under **`emulator-test/`** as **`NN-kebab-slug.md`**.  
**Every file must include SSH bundle** (resolutions, `xrandr`, processes, log tails).


## Quick verification (SSH)

```bash
test -x /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh && echo wrap_ok
grep switchres /userdata/roms/ports/Fightcade.sh
head -6 /userdata/system/add-ons/fightcade/bin/xdg-open
bash -n /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh && echo syntax_ok
```
