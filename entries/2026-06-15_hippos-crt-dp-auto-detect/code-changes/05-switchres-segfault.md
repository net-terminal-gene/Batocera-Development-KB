# 05 — switchres segfault on apply

**Symptom:** `DISPLAY=:0 switchres 640 480 60 -i /etc/switchres.ini` → exit **139**.  
Calculate-only (`-c`) works. Blocks `hippos-resolution minTomaxResolution` and in-game mode switch.

**Binary (test box):** `/usr/bin/switchres` BuildID `94269d6af2e7cc612a720b906bf2e6da1ecd6c37`

## Not a hippos shell script fix

This is in the **switchres package/build**. Investigate:

1. Rebuild switchres from upstream Switchres against same SDL/X11 libs as HippOS image.
2. Run under `gdb` on device: `DISPLAY=:0 gdb -ex run -ex bt --args switchres 640 480 60 -i /etc/switchres.ini`
3. Compare with Batocera CRT Script switchres (apply works there on same CRT hardware class).

## Workaround note

Menu/boot CRT can work via kernel `video=` + firmware EDID even when subprocess apply segfaults (Phase 1 validated). **Per-game videomode switching remains broken** until this is fixed.

## emulatorlauncher path

`emulatorlauncher_impl.py` prefers ctypes `libswitchres.so` when available — verify that path on device vs subprocess fallback in `_crt_setmode()` / `hippos-resolution setMode`.
