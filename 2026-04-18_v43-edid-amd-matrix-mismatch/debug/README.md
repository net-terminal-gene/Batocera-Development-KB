# Debug — v43 EDID Wrong Matrix on AMD Re-Install

## Layout

| Directory | Contents |
|-----------|----------|
| [pre-fix/](pre-fix/) | SSH snapshot logs **before** `03_backup_restore.sh` syslinux/EFI fixes (2026-04-18–19). Numbered `NN-slug.md`. |
| [fix/](fix/) | New logs after deploying the fix; same naming pattern as `pre-fix/`. **X11-only** lab. |
| [fix-wayland/](fix-wayland/) | **Wayland (HD) + X11 (CRT)** track; **install X11 / CRT Script first** (see [fix-wayland/README.md](fix-wayland/README.md)), then numbered steps. |

## Test scope (pre-fix)

These notes are from **X11-only** Batocera (stock display stack: **xorg**, `DISPLAY=:0`, **xrandr**). This session **does not** cover the **two-kernel Wayland (HD) / X11 (CRT)** setup from PR #395. “HD” here means the **HDMI / desktop** output and resolution path **on the same X11 session**, not a separate Wayland boot.

Numbered entries in **pre-fix/** (newest context at bottom of list):

| File | Summary |
|------|---------|
| [00-v43-x11-first-boot.md](pre-fix/00-v43-x11-first-boot.md) | 2026-04-18 local AMD lab: Batocera 43, RX 7700/7800 XT, `TYPE_OF_CARD_DRIVERS.info` = AMD/ATI, no `generic_15.bin` yet, dual-head xrandr baseline |
| [01-crt-script-pre-reboot.md](pre-fix/01-crt-script-pre-reboot.md) | Same machine: full v43 interactive install, DP-1, `generic_15` + **768x576@25**, menu shows **320/640/768** (native matrix), overlay lists `generic_15.bin`, reboot pending |
| [02-crt-mode-pre-mode-switcher.md](pre-fix/02-crt-mode-pre-mode-switcher.md) | Post-reboot CRT baseline before HD↔CRT switcher: `EDID build: switchres 769 576 25`, `TYPE_OF_CARD=AMD/ATI`, IFE=1 DCN, xrandr **769x576** on DP-1, no 1280 superres in log |
| [03-mode-switcher-crt-to-hd-pre-reboot.md](pre-fix/03-mode-switcher-crt-to-hd-pre-reboot.md) | **X11** CRT→HDMI before reboot: `batocera.conf` **HDMI-2**; syslinux still CRT EDID on `APPEND`; live **DP-1** 769×576; no dual-boot markers (**expected**, not testing Wayland/PR395) |
| [04-hd-mode-pre-mode-switcher.md](pre-fix/04-hd-mode-pre-mode-switcher.md) | **X11** HD mode after reboot: **HDMI-2** primary **3440×1440**, `videomode=default`; **DP-1** still connected; syslinux still `drm.edid_firmware` for DP-1; `stat generic_15.bin` failed at path (see note) |
| [05-mode-switcher-hd-to-crt-no-boot-recognition.md](pre-fix/05-mode-switcher-hd-to-crt-no-boot-recognition.md) | Why HD→CRT asks again: `videomode=default` in HD = no `Boot_*` for `get_crt_boot_resolution`; “saved” = `mode_backups/` files, not only `batocera.conf` |
| [06-mode-switcher-hd-to-crt-pre-reboot.md](pre-fix/06-mode-switcher-hd-to-crt-pre-reboot.md) | After switcher **target crt** + save: `batocera.conf` **DP-1** + mode ID; **mode_backups** filled; **xrandr** still **HDMI-2** primary until reboot; log shows `Boot:` empty then `Boot_576i` saved |
| [07-crt-mode-pre-mode-switcher.md](pre-fix/07-crt-mode-pre-mode-switcher.md) | CRT again post–HD round trip: **DP-1** primary **769×576**, `EDID build` still **769 576 25**, `generic_15.bin` OK; compare to [02](pre-fix/02-crt-mode-pre-mode-switcher.md) |
| [08-mode-switcher-crt-to-hd-pre-reboot.md](pre-fix/08-mode-switcher-crt-to-hd-pre-reboot.md) | **2nd** CRT→HD pre-reboot: `Config check` shows **HD: HDMI-2** (not empty); `17:51:06` save; live still **DP-1** until reboot vs [03](pre-fix/03-mode-switcher-crt-to-hd-pre-reboot.md) |
| [09-hd-mode-pre-mode-switcher.md](pre-fix/09-hd-mode-pre-mode-switcher.md) | **2nd** HD post-reboot: **HDMI-2** **3440×1440**, `default` videomode; same pattern as [04](pre-fix/04-hd-mode-pre-mode-switcher.md); `stat generic_15.bin` fails |
| [10-mode-switcher-hd-to-crt-pre-reboot.md](pre-fix/10-mode-switcher-hd-to-crt-pre-reboot.md) | **2nd** HD→CRT pre-reboot: `Config check` shows **Boot: Boot_576i…** (not empty); why first HD save seeds `mode_backups` ([05](pre-fix/05-mode-switcher-hd-to-crt-no-boot-recognition.md)) |

## Post-fix testing

Add new steps under [fix/](fix/). See [fix/README.md](fix/README.md) for the filename pattern and suggested capture commands.

## Wayland + X11 (PR #395 style) testing

Use [fix-wayland/](fix-wayland/) for **Wayland** **HD** factory path, **CRT Script X11 install** from Wayland, then dual-stack checks. **Prerequisite:** complete **X11** install (**fix-wayland/01**) before **`02+`** steps. See [fix-wayland/README.md](fix-wayland/README.md).

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

### Syslinux / cmdline (after `03_backup_restore.sh` fix)

```bash
cat /proc/cmdline
for f in /boot/EFI/syslinux.cfg /boot/boot/syslinux.cfg /boot/EFI/batocera/syslinux.cfg; do
  echo "=== $f ==="
  grep -E 'APPEND|drm.edid_firmware|video=' "$f" 2>/dev/null | head -5
done
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
| EDID active mode is `769x576` on AMD | Often v43 EDID pre-bump for AMD (`~3640`); not proof of NVIDIA-only path without `edid-decode` |
| EDID file mtime older than last reboot | Stale file, install script not actually re-run despite tester believing so |
| `videomodes.conf` head shows `1280x*` modes on AMD | Wrong videomodes folder copied (line 3723–3727 took NVIDIA-NOUV path) |
| `BUILD_15KHz_Batocera.log` shows `EDID build: switchres 1280 240 60 ...` | Confirms wrong branch picked |
| `BUILD_15KHz_Batocera.log` shows `EDID build: switchres 768 576 25 ...` | EDID was built correctly — file on disk is stale or test was misread |
| `/proc/cmdline` missing `drm.edid_firmware` after mode switch | Syslinux restore path (see `03_backup_restore.sh` fix) |
