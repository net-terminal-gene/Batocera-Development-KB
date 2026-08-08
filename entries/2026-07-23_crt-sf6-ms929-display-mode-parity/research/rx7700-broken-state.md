# RX 7700 XT Broken State (SF6 looks soft)

Host: `batocera.local` (also worked as `root@batocera`). Captured across 2026-07-22 session. Machine was **powered off** when BC-250 golden audit was taken — re-verify on next boot.

## Host / GPU

| Field | Value |
|-------|-------|
| Batocera | 43.1 (same train as BC-250) |
| GPU 0 | RTX 3090 (present in PCI; NVIDIA modules blacklisted for CRT boot) |
| GPU 1 | **RX 7700 XT** Navi32 `[1002:747e]`, RADV |
| Monitor | ms929 |
| Live CRT connector | **DP-2** (BootRes: renumbered from **DP-5** after NVIDIA blacklist) |
| cmdline pattern | `drm.edid_firmware=DP-2:edid/ms929.bin` + `module_blacklist=nvidia,...` |

Related: `entries/2026-07-22_crt-dual-gpu-clash-boot-rescan/` (DP-5 vs DP-2 clash).

## Batocera video keys (after restore toward CRT defaults)

```
global.videomode=641x480.60.00082
es.resolution=641x480.60.00082
es.customsargs=--screensize 641 480 --screenoffset 00 00
steam.videomode=854x480.60.00068
steam["1364780_Street_Fighter_6.sh"].videomode=854x480.60.00068
global.videooutput=DP-5    # STALE — live connector is DP-2
```

ES alone at Boot_480i is expected for CRT menu. Steam/SF6 switches toward 854.

## Critical: SF6 mode list when soft

Observed `config.ini` (BUA path):

```
.../add-ons/steam/.local/share/Steam/steamapps/common/Street Fighter 6/config.ini
```

Example when soft / “settings do nothing”:

```
FullScreenDisplayMode=0   # or 1 after some experiments
DisplayModeCount=13
DisplayMode0 = 320×180
DisplayMode1 = 320×240
…
DisplayMode11 = 641×480
DisplayMode12 = 854×480
```

So index `0` is **not** 640×480. Forcing `FullScreenDisplayMode=12` worked briefly; **game rewrote it back to 0** while running / on exit.

xrandr on this box listed many modes below 640×480 (unlike BC-250’s three).

## Steam stack differences

| Item | RX 7700 | BC-250 |
|------|---------|--------|
| Steam | BUA add-ons (`/userdata/system/add-ons/steam`) | Flatpak |
| Launcher | `/userdata/roms/steam/1364780_Street_Fighter_6.sh` | `Street Fighter 6.steam` |
| Proton | (BUA / Steam default — re-check live) | Proton Experimental 11.0-100 |
| exe MD5 | `fbd76345e90639aace9e3583c1d514ac` | same |
| buildid | `23395122` | same |

Flatpak Steam was installed experimentally on 7700, SF6 symlinked, then Flatpak later removed by user — **did not fix** softness alone.

## Experiments that failed or made things worse

| Experiment | Result |
|------------|--------|
| Match AA/DoF/shadows to BC-250 | No visual parity |
| AA=None | Looked more pixelated |
| `FullScreenDisplayMode=12` only | Game resets index |
| xrandr `--delmode` junk | `BadAccess` / modes return |
| Force ES to 854 after killall | Mode fight, dual ES, black/flashing |
| Exclusive fullscreen | Boot/credits/menu bad; reverted |
| 1280×480 videomode | Crash / exit ~8s |
| Config.ini force + watcher in launcher | Band-aid; does not replace short mode list |

## Restored / leave-alone after thrash

- Restored `batocera.conf` from `batocera.conf.bak.dp-retarget-20260722182740` (CRT DP retarget era)
- Boot `es.resolution=641x480.60.00082`
- Launcher may still contain `sf6-force-display-mode.sh` / watcher hooks under `/userdata/system/configs/steam/` — treat as temporary; Phase B mode allowlist is the real fix

## What success looks like on this box

Match BC-250:

1. `xrandr --current` ≤ 3 modes on DP-2 while SF6 runs  
2. `DisplayModeCount=3`, `DisplayMode0_Width=640` (or only 640/641/854)  
3. After quit+relaunch, index `0` still maps to a real 480-line mode  
4. Visual parity with BC-250 on same CRT/ms929  
