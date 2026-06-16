# HippOS CRT — DP auto-detect and switchres apply failures

## Agent/Model Scope

Composer + ssh to `hippos.local` and `batocera.local` for live comparison. Batocera CRT Script knowledge for reference implementation. Local clone: `~/hippos-linux`.

## Problem

HippOS CRT mode on `hippos.local` (v0.4.17, Navi 32 / RDNA3, DP-1 + DP-to-VGA DAC) produces completely wrong video on a 15 kHz CRT. The same physical setup works under Batocera with Batocera CRT Script on `batocera.local` (BC-250, same DP-1 path).

Fresh-flash defaults use `crt.enabled=auto`, which does not activate CRT on DisplayPort.

## Root Cause

Multiple stacked failures (see `research/README.md`, `research/auto-detect-limits.md`):

1. **`crt.enabled=auto` gate** — only VGA/DVI-I + zero-byte EDID; skips DP-1.
2. **CRT setup runs after X** — `hippos-xorg-setup` does not call `hippos-crt-setup`.
3. **`xrandr --auto` in xserver ExecStartPost** — pushes 31 kHz modes.
4. **Missing kernel `video=`** when setup never ran on prior boot.
5. **switchres segfault on apply** (exit 139).
6. **DCN `interlace_force_even=0`** when detection fails.
7. **ES exposes only 2 of 4 required keys** — no output or boot resolution UI; `auto` implied for fresh users.

Wrong mode: `640x480 DoubleScan` (~31 kHz). Working reference: `641x480i` @ ~15.7 kHz (Batocera CRT Script).

---

## Session phases (one loop)

### Phase 1 — Workaround validated ✅

Operator path on `hippos.local` (2026-06-15):

```bash
hippos-settings set crt.enabled true
hippos-crt-setup
reboot
```

Result: `641x480i` @ 15.78 kHz, ES readable on CRT. See `debug/01-workaround-validated.md`.

HippOS persistence: `/etc` via `@overlay`; GRUB on rw `/boot/efi` (no `batocera-save-overlay`).

### Phase 2 — Pipeline fixes (TBD, hippos-linux)

Backend changes so ES/manual config works on **first reboot**:

1. Call `hippos-crt-setup` from `hippos-xorg-setup` when `crt.enabled=true`.
2. Skip `ExecStartPost xrandr --auto` when CRT active.
3. Fix switchres apply segfault.
4. Improve DCN `interlace_force_even` without debugfs.
5. Optionally deprecate or remove `crt.enabled=auto` default (`false` on flash).

| Repo | File | Change |
|------|------|--------|
| hippos-linux | `overlays/.../hippos-display-setup` | Align auto gate OR defer to Phase 3 manual-only |
| hippos-linux | `overlays/.../hippos-xorg-setup` | Pre-X `hippos-crt-setup` when CRT enabled |
| hippos-linux | `overlays/.../hippos-xserver.service` | Guard `--auto` |
| hippos-linux | switchres package | Fix segfault |
| hippos-linux | `overlays/.../hippos-crt-setup` | DCN detection |

### Phase 3 — ES manual CRT section (TBD, enhancement)

Recommended UX: dedicated **System Settings → CRT** with Enable, Video Output, Monitor Profile, Boot Resolution (profile-filtered). Reboot on save. **`auto` not offered in UI.**

Full spec: `design/crt-es-settings-proposal.md`.

| Repo | File | Change |
|------|------|--------|
| hippos-emulationstation | `es-app/src/guis/GuiMenu.cpp` | CRT section (4 controls) |
| hippos-linux | `hippos-resolution` or new helper | `listCrtBootModes` by profile |
| hippos-linux | defaults | `crt.enabled=false` on fresh flash |

Phase 2 and 3 can ship in one PR or ES UI after pipeline fixes; both target the same user journey.

**Implementation snippets:** [code-changes/](code-changes/) (current vs recommended code per file).

---

## Validation

### Phase 1 (workaround) — done

- [x] `/proc/cmdline` has `video=DP-1:640x480ieS` + `drm.edid_firmware` after setup + reboot
- [x] `641x480i` @ ~15.7 kHz active (not DoubleScan)
- [x] ES menu readable on CRT (operator confirmed)
- [x] Timing class matches Batocera CRT Script reference

### Phase 2 (pipeline)

- [ ] `crt.enabled=true` + ES reboot (no manual `hippos-crt-setup`) → correct CRT on **first** reboot
- [ ] `switchres … -i /etc/switchres.ini` exits 0 (no segfault)
- [ ] Per-game videomode switch + restore to boot resolution

### Phase 3 (ES UX)

- [ ] CRT section exposes output picker (connected DRM ports)
- [ ] Boot resolution list filters by monitor profile
- [ ] Save triggers reboot prompt; after reboot, CRT correct without SSH
- [ ] Fresh flash default: CRT off until user enables

### Auto (optional / legacy)

- [ ] If kept: DP + zero-byte EDID only — never “first connected port” without EDID check
- [ ] Document that auto is not supported for typical DP-DAC setups
