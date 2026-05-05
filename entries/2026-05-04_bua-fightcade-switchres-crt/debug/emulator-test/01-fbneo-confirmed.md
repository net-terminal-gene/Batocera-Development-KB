# 01 — FBNeo: confirmed working

**Status:** PASS (both first launch, repeated same-session, and ES round-trip)

---

## Mandatory bundle

### xrandr during KOF98 TEST GAME

```text
Screen 0: minimum 320 x 200, current 320 x 224, maximum 16384 x 16384
DP-1 connected primary 320x224+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98 +
   641x480       60.00
   SR-1_320x224@59.19  59.19*
```

### Processes

```text
17651 /bin/bash .../bin/xdg-open fcade://play/fbneo/kof98
17653 /bin/bash .../extra/switchres_fightcade_wrap.sh fcade://play/fbneo/kof98
17858 .../usr/bin/wine .../fbneo/fcadefbneo.exe kof98
17887 .../fbneo/fcadefbneo.exe kof98
```

### Games tested

| Game | ROM | Resolution | Refresh | Result |
|------|-----|-----------|---------|--------|
| Street Fighter III: 3rd Strike | `sfiii3nr1` | 384x224 | 59.60 Hz | PASS |
| King of Fighters 98 | `kof98` | 320x224 | 59.19 Hz | PASS |

### Scenarios tested

| Scenario | Result |
|----------|--------|
| First TEST GAME (cold Fightcade launch) | PASS |
| Repeated TEST GAME (same session, no quit) | PASS |
| Exit Fightcade to ES, relaunch, TEST GAME | PASS |
| Switch between SF3 and KOF98 (different resolutions) | PASS |

---

## Notes

- Switchres correctly picks per-game native resolution via MAME `-listxml`
- `--rmmode` fix prevents duplicate `add_mode` on repeated launches
- Wine + `fcadefbneo.exe` process chain healthy throughout
- Menu timing (641x480@60) restores cleanly after each game exit
