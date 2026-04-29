# Debug -- CRT EmulationStation Theme for 320x240

## Verification

```bash
# Check current ES resolution on CRT
batocera-resolution currentMode
batocera-resolution listModes

# Check what theme ES is using
batocera-settings-get global.theme

# Check if tinyScreen is active (look in ES log)
cat /userdata/system/logs/es_log.txt | grep -i "small\|tiny\|screen\|resolution"

# Deploy theme to device
rsync -avz ./es-theme-carbon-crt/ root@batocera:/userdata/themes/es-theme-carbon-crt/

# Set theme via settings
batocera-settings-set global.theme es-theme-carbon-crt

# Restart ES to apply
batocera-es-swissknife --restart
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Text unreadable / too small | Font sizes not large enough for 240p; check fontSize values in layout XML |
| UI elements overlap | Positions not adjusted for 4:3 or low pixel count |
| Theme not appearing in ES settings | Missing or malformed theme.xml; check `<formatVersion>7</formatVersion>` |
| Theme loads but looks like default Carbon | tinyScreen override not triggering; verify `if=` or `tinyScreen` conditionals |
| Images blurry or oversized | Assets not downscaled for 320x240; check art/ dimensions |
| ES crashes on theme load | Malformed XML; check es_log.txt for parse errors |
| Subset options missing | Subset not defined in root theme.xml or XML syntax error |
| Black screen after theme switch | Theme file not found; verify path in `/userdata/themes/` |
