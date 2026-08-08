# Debug — CRT SF6 / ms929 Display Mode Parity

## SSH

```bash
# Good box
~/bin/ssh-batocera.sh 10.23.6.116 "command"

# Bad box
~/bin/ssh-batocera.sh batocera.local "command"
```

Prefer scp + remote `bash /tmp/script.sh` for multi-line work.

## Pass criteria (7700 must match)

| Check | Golden (BC-250) | Command |
|-------|-----------------|---------|
| xrandr mode count on CRT | 3 | `DISPLAY=:0 xrandr --current \| awk '/ connected/,/^[^ ]/'` |
| SF6 DisplayModeCount | 3 | `grep DisplayModeCount …/config.ini` |
| DisplayMode0 | 640×480 | `grep DisplayMode0_ …/config.ini` |
| Window size | 854×480 | `DISPLAY=:0 wmctrl -lG \| grep -i Street` |
| Desktop while in game | 854×480 | `DISPLAY=:0 batocera-resolution currentResolution` |
| exe identity | MD5 `fbd76345…` | `md5sum …/StreetFighter6.exe` |

## Quick compare script (run on each host)

```bash
#!/bin/bash
export DISPLAY=:0
echo "HOST=$(hostname)"
echo "MODE=$(batocera-resolution currentMode)"
echo "RES=$(batocera-resolution currentResolution)"
echo "XRANDR_MODES=$(xrandr --current | awk '/^[[:space:]]+[0-9]+x/{c++} END{print c+0}')"
CFG=$(find /userdata -path '*Street Fighter 6/config.ini' 2>/dev/null | head -1)
echo "CFG=$CFG"
[ -n "$CFG" ] && tr -d '\r' < "$CFG" | grep -E '^(FullScreenDisplayMode|WindowMode|DisplayModeCount|DisplayMode0_|AntiAliasing|ImageQualityRate|Capability)='
[ -n "$CFG" ] && md5sum "$(dirname "$CFG")/StreetFighter6.exe"
wmctrl -lG 2>/dev/null | grep -iE 'Street|Fighter' || true
```

## Re-audit 7700 after power-on

Copy and run the audit used for BC-250:

- Local: KB `research/` or regenerate from session scripts `/tmp/sf6-full-audit2.sh`
- Save as `research/rx7700-sf6-full-audit.out` in this entry

## Failure signs

| Symptom | Likely cause |
|---------|----------------|
| Soft/pixelated menu + match | `DisplayMode0` tiny; index 0 selected |
| Settings “do nothing” | Index rewritten to 0; Borderless window size unchanged |
| Credits sharp, 3D soft | Different code path; still check mode index for 3D |
| Black + flashing after SSH work | Dual openbox/ES or mode thrash — single `S31emulationstation` restart, restore Boot_480i |
| `videooutput=DP-5` but CRT on DP-2 | Dual-GPU renumber; update output + see dual-gpu KB entry |
| Flatpak install, still soft | Mode list not fixed yet |

## Do not do

- Kill ES repeatedly / overlapping `S31` starts
- Force ES to 854 to “fix” SF6
- Rely only on `sed` of `FullScreenDisplayMode` without shortening xrandr modes
- Assume `batocera-resolution listModes` length equals what SF6 sees
