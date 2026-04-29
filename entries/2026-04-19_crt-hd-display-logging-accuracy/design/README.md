# Design — CRT / HD display logging accuracy

## Architecture

### Log roles (target end state)

| Log / source | Should answer | Must not be mistaken for |
|--------------|---------------|---------------------------|
| **`BootRes.log`** | What the **installer / boot path** recorded for monitor profile and chosen boot timing | Sole source for **post-switcher** **`global.videomode`** or **live X mode** |
| **`BUILD_15KHz_Batocera.log`** **`EDID build:`** | **EDID blob** generation inputs (**switchres** line) | Current **X11** desktop resolution after user picks **Boot_480i** etc. |
| **`display.log`** | **Splash / checker / setMode** sequence for this boot | Clean-room truth without reading **`none`** / timeout lines in context |

### Flow (conceptual)

```
Installer / CRT Script  →  BootRes (install-time snapshot?)
Mode switcher save      →  batocera.conf + mode_backups
CRT Script EDID path    →  BUILD (EDID build line)
batocera-display / ES   →  display.log
```

Solidify arrows after **research** identifies actual writers and call order.
