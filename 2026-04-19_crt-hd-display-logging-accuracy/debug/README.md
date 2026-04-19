# Debug — CRT / HD display logging accuracy

## Verification

After any logging change, capture in one SSH session:

```bash
batocera-settings-get global.videomode
batocera-settings-get global.videooutput
DISPLAY=:0.0 xrandr | head -20
cat /userdata/system/logs/BootRes.log
grep 'EDID build' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -5
tail -30 /userdata/system/logs/display.log
```

Compare **five** surfaces: **settings**, **X**, **`BootRes`**, **`BUILD`**, **`display.log`**.

## Failure signs

| Symptom | Likely cause |
|---------|----------------|
| **`BootRes`** disagrees with **`xrandr`** after mode switch only | **BootRes** not refreshed post-switcher (expected until fix) |
| **`EDID build`** shows **769×576** but user chose **480i** | Misread: **EDID** profile vs **desktop** mode (expected until doc/fix) |
| Black screen but logs look “fine” | Do not trust **`BootRes`** alone; check **`display.log`** **`setMode`** and **`batocera.conf`** |
