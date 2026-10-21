# Debug — Fightcade Flatpak HD Video Settings

## Verification

```bash
# Resolve which snes9x conf is actually read (symlink target)
D=/userdata/saves/flatpak/binaries/app/com.fightcade.Fightcade/x86_64/stable/*/files/fightcade/Fightcade
ls -la $D/emulator/snes9x/fcadesnes9x.conf          # -> /var/data/config/snes9x/fcadesnes9x.conf

# Confirm Lock state + current bindings on the live (writable) conf
CONF=/userdata/saves/flatpak/data/.var/app/com.fightcade.Fightcade/data/config/snes9x/fcadesnes9x.conf
grep -nE "^Lock " "$CONF"                            # want: Lock = FALSE
grep -nE "Joypad1:(A|B|Start) " "$CONF"

# Authoritative Lock semantics come from the pristine template
grep -n "^Lock " $D/emulator/snes9x/fcadesnes9x.default.conf

# What snes9x logged about its config path
cat $D/emulator/snes9x/stdout.txt                    # "Reading config file Z:\app\...\fcadesnes9x.conf."

# Local syntax check after editing the patcher
bash -n hd/patch-hd-video.sh
```

## End-to-end persistence test (needs physical input)

1. Launch a SNES game in Test Mode (reads `Lock=FALSE`).
2. Remap the controller in the emulator input dialog.
3. Exit via SELECT+Start; re-enter.
4. Expect: bindings persist. Verify on host that `Joypad1:*` now show joystick assignments and the conf mtime advanced past the launch time.

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| SNES controller reverts to keyboard after re-entry | `[Config] Lock = TRUE` (config read-only; snes9x can't save) |
| Game launches in a small window with a menu bar | `patch-hd-video.sh` didn't run, or preset missing (stock 640x480, `HideMenu=FALSE`) |
| Wrong (squished) aspect | `Stretch:AspectRatioBaseWidth = 256` (stock) instead of `299` |
| Screen tearing | `Vsync = FALSE` / `bVidVSync 0` / `rend.vsync = no` |
| Fullscreen at 1080p on a 1280x800 Deck | resolution overlay skipped (presets hardcode 1920x1080) |
