# Design — v43 EDID Wrong Matrix on AMD Re-Install

## Code paths involved

### Install script: `Batocera-CRT-Script-v43.sh`

| Lines | Purpose |
|---|---|
| 260 | Welcome screen lists `Boot_576i 1.0:0:0 15KHz 50Hz` choice (this string is the "smoking gun" — it only exists here, NOT in the mode switcher) |
| 3509–3522 | AMD/ATI / NVIDIA-with-Nvidia-Drivers / Intel-on-DP branch → native matrix (`generic_15 320x240@60 640x480@30 768x576@25`) |
| 3542–3551 | Else branch (Intel / NVIDIA-NOUV) → superres matrix (`generic_15 1280x240@60 1280x480@30 1280x576@25`) |
| 3613–3621 | NVIDIA-only `H_RES_EDID + 1` pre-bump |
| 3658 | `switchres $H_RES_EDID $V_RES_EDID $FREQ_EDID -f $FORCED_EDID -i switchres.ini -e` builds EDID file |
| 3683–3696 | NVIDIA-NOUV / NVIDIA-fallback post-bump |
| 3723–3727 | Copies `videomodes.conf` from `Amd_NvidiaND_IntelDP/` or `Intel_Nvidia_NOUV/` based on which branch fired |

### Mode switcher: `Geometry_modeline/mode_switcher_modules/`

- `03_backup_restore.sh` lines 935–944: reads EDID file to extract H/V range for `15-crt-monitor.conf`
- **No write to `/lib/firmware/edid/`. No `switchres -e` invocation anywhere.**
- Only backs up/restores `syslinux.cfg` between modes.

### Geometry tool: `Geometry_modeline/geometry.sh`

- Line 389: `switchres ... -e` writes to `custom.bin` — NOT `generic_15.bin`. Cannot be the cause.

## Flow that produced the bug

1. **Boot 1** (initial CRT): install ran with AMD branch → EDID `768x576@25` preferred, 485mm × 364mm. ✓
2. **Boot 2** (after HD switch via mode switcher): reboot → HD works. HDMI-1 1920x1080 active, DP-1 disconnected (CRT physically off).
3. **Boot 3** (back to CRT): user states he chose `Boot_576i 1.0:0:0 15KHz 50Hz`. That menu string only exists in the install script's welcome → install script was re-run.
4. Re-run took Intel/NVIDIA-NOUV branch on his AMD card → EDID rebuilt with `1280x240@60 …`, 400mm × 300mm.
5. xrandr in CRT mode boot 3 shows `1280x240 59.68 +` preferred, active `769x576 50` (with NVIDIA `+1` bump applied even though card is AMD).

## Detection conditions (line 3509)

```bash
if ([ "$TYPE_OF_CARD" == "NVIDIA" ] && [ "$Drivers_Nvidia_CHOICE" == "Nvidia_Drivers" ]) \
   || ([ "$TYPE_OF_CARD" == "AMD/ATI" ]) \
   || ([ "$TYPE_OF_CARD" == "INTEL" ] && [[ $video_output == *"DP"* ]]); then
  # native matrix
else
  # superres matrix
fi
```

For the bug to manifest on AMD RX6400, `TYPE_OF_CARD != "AMD/ATI"` on the second run. Need to know what value got assigned and why.
