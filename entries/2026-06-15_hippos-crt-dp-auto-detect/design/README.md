# Design — HippOS CRT

## Documents

| File | Content |
|------|---------|
| [crt-boot-flow.md](crt-boot-flow.md) | Intended vs actual boot pipeline, ES today, gap list, code map |
| [crt-es-settings-proposal.md](crt-es-settings-proposal.md) | **Phase 3** — manual CRT section in ES, profile-filtered boot resolutions, drop auto |

## Architecture (summary)

See [crt-boot-flow.md](crt-boot-flow.md) for the mermaid diagram.

**Target user journey (after Phases 2–3):**

```
Flash → CRT off by default
     → User: System Settings → CRT → Enable + pick Output + Profile + Boot resolution
     → Reboot once
     → Kernel video= + firmware EDID + Xorg CRT conf + ES at 15kHz-class menu mode
```
