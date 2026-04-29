# 06 - Mode switcher HD to CRT, pre-reboot (fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Scope:** X11-only ([../README.md](../README.md)).

**Step 05:** Intentionally **not** duplicated here. Same expected behavior as [pre-fix 05](../pre-fix/05-mode-switcher-hd-to-crt-no-boot-recognition.md) (`mode_backups/`, `get_crt_boot_resolution`, empty **Boot** until save). No separate fix log.

## Definition

- **HD to CRT** via mode switcher (**`target: crt`**), **`Mode switch UI completed successfully`**, **before reboot**.
- **`batocera.conf`** already CRT-oriented; **live** session can still show **HDMI** primary until reboot.

Follows [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md). (Skipped **05**: see above.)

## Commands run

```bash
batocera-version
grep -n 'global.video' /userdata/system/batocera.conf
grep -n 'global.videomode' /userdata/system/batocera.conf
DISPLAY=:0.0 xrandr | head -22
grep -A3 'MENU DEFAULT' /boot/boot/syslinux/syslinux.cfg | head -8
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_output.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_output.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt
grep -E 'Mode switch|Config check|Saving selections|Converting boot' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -30
```

Extra (same session): **`grep APPEND`** on **`/boot/boot/syslinux/syslinux.cfg`**, **`/boot/EFI/batocera/syslinux.cfg`**, **`/boot/EFI/syslinux.cfg`**.

**Note:** `grep 'global.video'` also lists **`global.videomode=`** lines because of the shared **`video`** substring. Use the **`grep … videomode`** block for mode lines.

## Captured output

### batocera-version

```
43ov 2026/04/07 09:23
```

([Inference] Treat as Batocera **43** if the `ov` suffix is a terminal artifact.)

### `batocera.conf` (video-related)

From the **`global.videomode`** grep (authoritative for mode line):

```
384:global.videomode=769x576.50.00053
385:global.videooutput=DP-1
```

(`global.videooutput2` not re-grepped in this capture; typically **`none`** in this ladder.)

### `xrandr` (head)

- **Screen:** current **3440 × 1440**.
- **HDMI-2:** **connected primary** **3440×1440+0+0** (`*+`).
- **DP-1:** connected, **not** primary in this snapshot.

**Interpretation:** **userdata** already targets **CRT** (**DP-1**, **769x576.50.00053**); **live** stack still **HDMI** primary until reboot.

### `syslinux` (**MENU DEFAULT** excerpt, `/boot/boot/syslinux/syslinux.cfg`)

```
	MENU DEFAULT
	LINUX /boot/linux
	APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0 mitigations=off  usbhid.jspoll=0 xpad.cpoll=0 drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e
	INITRD /boot/initrd.gz
```

### `APPEND` (all three paths)

CRT **`drm.edid_firmware=DP-1:edid/generic_15.bin`** and **`video=DP-1:e`** present on:

- **`/boot/boot/syslinux/syslinux.cfg`**
- **`/boot/EFI/batocera/syslinux.cfg`**
- **`/boot/EFI/syslinux.cfg`**

So **CRT restore** propagated the EDID **`APPEND`** everywhere checked (matches the **fix** for single-boot propagation).

### `mode_backups/` (video settings)

| File | Content |
|------|---------|
| `hd_mode/video_settings/video_output.txt` | `global.videooutput=HDMI-2` |
| `crt_mode/video_settings/video_output.txt` | `global.videooutput=DP-1` |
| `crt_mode/video_settings/video_mode.txt` | `global.videomode=769x576.50.00053` |

### `BUILD_15KHz_Batocera.log` (mode switcher excerpts)

```
[18:53:32]: Mode switch UI started for target: hd
[18:53:32]: Config check - HD: , CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[18:53:40]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[18:53:40]: Converting boot mode - input: 'Boot_576i 1.0:0:0 15KHz 50Hz', output: '769x576.50.00053'
[18:53:40]: Mode switch UI completed successfully
[18:57:51]: Mode switch UI started for target: crt
[18:57:51]: Config check - HD: HDMI-2, CRT: DP-1, Boot: 
[18:57:59]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[18:57:59]: Converting boot mode - input: 'Boot_576i 1.0:0:0 15KHz 50Hz', output: '769x576.50.00053'
[18:57:59]: Mode switch UI completed successfully
```

**`target: crt`** line shows **`Boot:`** empty at **Config check** (`18:57:51`), then **Boot_576i** saved at **`18:57:59`**. Same pattern documented in [pre-fix 05](../pre-fix/05-mode-switcher-hd-to-crt-no-boot-recognition.md) (expected).

## Findings

| Check | Result |
|-------|--------|
| `batocera.conf` | **DP-1**, **769x576.50.00053** |
| Live `xrandr` primary | Still **HDMI-2** / **3440×1440** (pre-reboot) |
| `mode_backups/` | **HD** and **CRT** video settings files populated |
| On-disk **`APPEND`** | **CRT EDID** params on **all three** checked syslinux paths |

## Next

- **07:** [07-crt-mode-pre-mode-switcher.md](07-crt-mode-pre-mode-switcher.md) (CRT after HD→CRT reboot). Twin: [pre-fix 07](../pre-fix/07-crt-mode-pre-mode-switcher.md).

## Reference

- [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md)  
- [../pre-fix/06-mode-switcher-hd-to-crt-pre-reboot.md](../pre-fix/06-mode-switcher-hd-to-crt-pre-reboot.md)  
- **05 (skipped):** [../pre-fix/05-mode-switcher-hd-to-crt-no-boot-recognition.md](../pre-fix/05-mode-switcher-hd-to-crt-no-boot-recognition.md)
