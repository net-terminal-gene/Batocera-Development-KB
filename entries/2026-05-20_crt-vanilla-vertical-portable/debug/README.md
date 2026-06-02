# Debug — Vanilla Batocera Vertical CRT (Portable Bundle)

## Verification

```bash
# After fresh install + CRT script + portable overlay
~/bin/ssh-batocera.sh "batocera-version"
~/bin/ssh-batocera.sh "grep display.rotate /userdata/system/batocera.conf"
~/bin/ssh-batocera.sh "DISPLAY=:0 batocera-resolution getRotation; DISPLAY=:0 batocera-resolution currentResolution"
~/bin/ssh-batocera.sh "grep -A5 gameStop /userdata/system/scripts/first_script_right.sh"
~/bin/ssh-batocera.sh "ls /userdata/system/configs/mame/*.cfg | wc -l"
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| ES horizontal after quitting MAME | `first_script_right` missing or `xrandr -o normal` on gameStop; run `apply-es-exit-rotation.sh` |
| ~30s black screen on exit | Multiple scripts calling `setRotation`; remove `~restore_*.sh` |
| MAME wrong orientation | Bulk 270 cfgs vs `mame.rotation=autorol` conflict; tune per game |
| PSX/PS2/PSP sideways | CRT installer rotation choice mismatch; check libretro vs standalone path in `first_script.sh` |
| No CRT modes | CRT installer not run or wrong Batocera/CRT script version pair |
| Black screen on boot (new GPU) | Wrong `videooutput` — use CRT installer for **your** output, not Myzar DP hack |

## Test checklist

- [ ] ES boots vertical (480×640 or installer-chosen TATE res)
- [ ] MAME launch → gameplay → quit → ES vertical within ~10s
- [ ] PSX game launches upright, acceptable aspect
- [ ] PS2 (PCSX2 or libretro) upright
- [ ] PSP (PPSSPP) upright
- [ ] New MAME zip gets cfg (if using generator) or autorol works
