# 02 — Set ES and Steam Video Mode to MAX 1920x1080

## Date: 2026-05-07

## Context

Configured EmulationStation and Steam Big Picture to run at maximum 1920x1080 before first Steam launch.

## Settings Applied (in `batocera.conf`)

```ini
es.resolution=max-1920x1080
steam["Steam_Big_Picture.sh"].videomode=max-1920x1080
```

## Other Relevant Config

```ini
system.services=symlink_manager custom_service_handler
system.cpu.governor=performance
steam.emulator=sh
steam.core=sh
kodi.enabled=1
audio.device=auto
audio.volume=90
system.timezone=America/Denver
```

## Display State (from batocera-info)

- Output: HDMI-2
- Resolution: 1920x1080
- Refresh: 60.00Hz
- Display Server: xorg
- Compositor: openbox

## Notes

- `es.resolution=max-1920x1080` caps ES to 1080p (won't try higher even if display supports it)
- `steam["Steam_Big_Picture.sh"].videomode=max-1920x1080` is a per-game override for the Steam Big Picture launcher specifically
- No `global.videomode` set (commented out), so emulators use default/auto
- No shader set configured
- CPU governor set to `performance` (no frequency scaling)
