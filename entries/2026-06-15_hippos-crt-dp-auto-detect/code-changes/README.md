# Code changes — handoff for hippos-linux maintainer

**Session:** `2026-06-15_hippos-crt-dp-auto-detect`  
**Repo:** [hippos-linux/hippos-linux](https://github.com/hippos-linux/hippos-linux) (+ `hippos-emulationstation` for Phase 3)

Mikey validated Phase 1 workaround on hardware; **not implementing** — this folder is the recommended patch guide.

## Read order

1. [../design/crt-es-settings-proposal.md](../design/crt-es-settings-proposal.md) — UX intent (manual CRT section)
2. [../design/crt-boot-flow.md](../design/crt-boot-flow.md) — why boot order matters
3. Files below — concrete edits

## Phase 2 — Pipeline (backend)

| # | File | Topic |
|---|------|--------|
| [02-hippos-xorg-setup.md](02-hippos-xorg-setup.md) | Run `hippos-crt-setup` **before** X when CRT enabled |
| [03-hippos-xserver-service.md](03-hippos-xserver-service.md) | Skip `xrandr --auto` when CRT active |
| [04-hippos-crt-setup-dcn.md](04-hippos-crt-setup-dcn.md) | Fix DCN `interlace_force_even` on Navi/RDNA |
| [05-switchres-segfault.md](05-switchres-segfault.md) | switchres apply crash (exit 139) — investigate/fix package |

Optional if keeping `auto` as legacy: [01-hippos-display-setup-auto-gate.md](01-hippos-display-setup-auto-gate.md)

## Phase 3 — Manual CRT UX

| # | File | Topic |
|---|------|--------|
| [01-defaults-manual-crt.md](01-defaults-manual-crt.md) | Default `crt.enabled=false`; update comments |
| [06-GuiMenu-crt-section.md](06-GuiMenu-crt-section.md) | ES: Output + Boot resolution pickers |
| [07-hippos-resolution-boot-modes.md](07-hippos-resolution-boot-modes.md) | New `listCrtBootModes` helper for ES |

## Validation (after patches)

```bash
# Fresh flash mental model: user enables CRT in ES, picks DP-1, reboots once
hippos-settings get crt.enabled crt.output crt.boot_resolution crt.monitor_profile
cat /proc/cmdline | tr ' ' '\n' | grep -E 'video|edid'
DISPLAY=:0 xrandr --verbose | grep -A6 'current'
DISPLAY=:0 switchres 640 480 60 -i /etc/switchres.ini; echo exit=$?
```

Expect: `641x480i` (or chosen boot mode) @ ~15 kHz; switchres exit 0.

## Reference: validated workaround (Phase 1)

```bash
hippos-settings set crt.enabled true
hippos-crt-setup
reboot
```

See [../debug/01-workaround-validated.md](../debug/01-workaround-validated.md).
