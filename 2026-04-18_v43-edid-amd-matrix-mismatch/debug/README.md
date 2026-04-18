# Debug — v43 EDID Wrong Matrix on AMD Re-Install

## Logs to collect from tester

```bash
# When was the EDID file last rebuilt?
stat /lib/firmware/edid/generic_15.bin

# What did the install script log as the user's choices?
cat /userdata/system/logs/BootRes.log

# What detection branch did the install script take, and what switchres command did it run?
grep -E 'TYPE_OF_CARD|video_output|Drivers_Nvidia_CHOICE|Amd_NvidiaND|Intel_Nvidia_NOUV|EDID build|H_RES_EDID|monitor_firmware|Engine detect' \
  /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -80

# Decode the EDID to confirm which modes are actually in it
edid-decode /lib/firmware/edid/generic_15.bin | head -40

# What other EDID files exist?
ls -la /lib/firmware/edid/

# Which videomodes folder did the install copy from? (Amd_NvidiaND_IntelDP/ or Intel_Nvidia_NOUV/)
ls -la /userdata/system/videomodes.conf
head -5 /userdata/system/videomodes.conf
```

## Verification (after fix)

```bash
edid-decode /lib/firmware/edid/generic_15.bin | grep -E 'DTD|Detailed|Hz'
xrandr --display :0.0 | grep -E '\*|\+'
```

Expected on AMD: preferred mode matches the menu pick (`768x576@25`), no `1280x240` superres in the EDID.

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| EDID has `1280x240` preferred on AMD card | Wrong matrix branch fired (else instead of if at v43:3509) |
| EDID active mode is `769x576` (one wider than native) on AMD | NVIDIA `+1` H_RES bump applied to non-NVIDIA card |
| EDID file mtime older than last reboot | Stale file, install script not actually re-run despite tester believing so |
| `videomodes.conf` head shows `1280x*` modes on AMD | Wrong videomodes folder copied (line 3723–3727 took NVIDIA-NOUV path) |
| `BUILD_15KHz_Batocera.log` shows `EDID build: switchres 1280 240 60 ...` | Confirms wrong branch picked |
| `BUILD_15KHz_Batocera.log` shows `EDID build: switchres 768 576 25 ...` | EDID was built correctly — file on disk is stale or test was misread |
