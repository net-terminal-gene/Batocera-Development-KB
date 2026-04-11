# Debug — CRT Graphics Settings Guide

## Verification

```bash
# Check current HD Mode resolution on Batocera
batocera-resolution currentResolution
batocera-resolution currentMode

# Verify FSR is active in Cyberpunk (check render resolution vs output)
# In-game: Settings > Graphics > Resolution Scaling should show FSR 2.1

# Check GPU governor is running (critical for BC-250 performance)
cat /sys/class/drm/card0/device/pp_dpm_sclk

# Monitor FPS in-game
# Cyberpunk has a built-in FPS counter: Settings > Video > Show FPS
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| FPS much lower than expected at 720p | GPU governor not running (locked at 1500 MHz) |
| Image looks worse than expected on CRT | Converter outputting 480p instead of 480i |
| Screen tearing despite VSync On | VSync not taking effect — check if game is using Vulkan vs OpenGL |
| FSR looks blurry/artifacted | Image Sharpening too high — set to 0 for CRT |
| UI text unreadable | Resolution too low or FOV too wide for 480i — try 1080p with FSR Quality |
