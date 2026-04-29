# Final Verdict: v43 Wayland/X11 Dual-Boot Development

**Status:** MERGED (PR #395, 2026-04-23)

**Date:** 2026-02-22 (session start) → 2026-04-23 (merge)

**Result:** Wayland/X11 dual-kernel architecture implemented, tested on AMD, merged into Batocera-CRT-Script main branch with v43. CRT tools visible on physical CRT after full HD↔CRT roundtrips.

---

## How Far Did the Final Code Deviate from the Initial Plan?

**Significantly.** The original plan (`plan.md`) was fundamentally wrong about the architecture. The actual implementation diverged in every major dimension.

### Original Plan (Overlay-Only Swap)

The plan assumed a single kernel could serve both Wayland and X11 by swapping overlays:

- Single boot entry, single kernel, single initrd
- Swap `/boot/boot/overlay` between HD (Wayland configs) and CRT (X11 configs)
- One-phase install: detect Wayland → apply CRT changes → save overlay → reboot
- Existing `backup_overlay_file` / `restore_overlay_file` logic would handle it

**Key assumption that was wrong:** "The overlay can only swap *what exists on the system*." The plan acknowledged this but assumed v43 would include both Wayland and X11 binaries. It did not. Wayland builds have no X11 server, no switchres, no xrandr. An overlay cannot conjure binaries that don't exist in the base image.

### What Actually Shipped (Dual-Kernel Syslinux Boot)

The real architecture required:

1. **Two separate kernels** — Wayland `linux`+`initrd.gz` at `/boot/boot/` and X11 `linux`+`initrd-crt.gz` at `/boot/crt/`, extracted from a separate X11 Batocera image
2. **Syslinux multi-entry boot** — `LABEL batocera` (Wayland) and `LABEL crt` (X11) with `DEFAULT` toggled by the mode switcher
3. **Two-phase install** — Phase 1 runs on Wayland (sets up boot environment, extracts X11 image, patches initrd, creates syslinux entries), Phase 2 runs on X11 after reboot (configures CRT display, saves CRT overlay)
4. **Separate overlays per kernel** — `/boot/boot/overlay` for Wayland, `/boot/crt/overlay` for CRT, each managed independently
5. **Userdata-only backup/restore** — Mode switcher swaps `batocera.conf`, scripts, RetroArch/MAME configs, and `es_settings.cfg` via backup dirs, NOT full overlay swaps
6. **`boot-custom.sh`** — Mode-aware init script that generates `15-crt-monitor.conf` on CRT boot and handles theme assets on HD boot
7. **`crt-launcher.sh`** — New wrapper script that syncs `global.videomode` with `batocera-resolution currentMode` before every `emulatorlauncher` invocation, preventing video mode precision mismatches
8. **Power cycle instead of reboot** — Cross-kernel transitions require full power cycle (GPU hardware register state doesn't clear on warm reboot)

### Plan vs Reality Summary

| Aspect | Plan | Reality |
|---|---|---|
| Boot architecture | Single kernel, overlay swap | Dual kernel, Syslinux multi-entry |
| X11 binaries | Assumed present in base image | Extracted from separate X11 image |
| Install phases | Single phase | Two phases across two boots |
| Overlay strategy | Swap single overlay | Separate overlay per kernel |
| Mode switching | Full overlay backup/restore | Userdata-only backup/restore + syslinux DEFAULT toggle |
| Display init | Assumed existing init worked | Required mode-aware `boot-custom.sh` |
| emulatorlauncher | Assumed no issues | Required `crt-launcher.sh` wrapper for precision mismatch |
| Reboot behavior | Standard reboot | Power cycle required for cross-kernel |

---

## Bugs That Were Not Anticipated by Any Plan

1. **Video mode string precision mismatch** — `videomodes.conf` stores `769x576.50.00060`, `batocera-resolution currentMode` returns `769x576.50.00`. `emulatorlauncher` does exact string comparison → triggers spurious `changeMode()` → breaks CRT display pipeline. This was the hardest bug and required the `crt-launcher.sh` wrapper plus Layer 2 fixes in the backup/restore logic.

2. **`batocera-resolution getCurrentMode` doesn't exist** — The CLI command is `currentMode`, not `getCurrentMode`. This typo caused the wrapper to silently fail for an entire debug cycle before being caught.

3. **`batocera-resolution currentMode` requires DISPLAY on X11** — SSH sessions don't have `DISPLAY` set, so the command returns empty. The wrapper needed `export DISPLAY="${DISPLAY:-:0.0}"`.

4. **Boot resolution re-ask on every switch** — `get_boot_display_name()` did exact string matching. After saving `769x576.50.00` (from `currentMode`), it couldn't match `769x576.50.00060` (from `videomodes.conf`) on the next switch. Required prefix-match fallback.

5. **Verification grep false positives** — After introducing `crt-launcher.sh`, existing verification greps for literal "emulatorlauncher" in `es_systems_crt.cfg` started failing, triggering misleading "INCORRECT" log messages and unnecessary file re-copies.

---

## Models Used

| Phase | Model | Notes |
|---|---|---|
| Research & initial plan | Unknown | Pre-dates this session's context window |
| Design docs (architecture, flows) | Unknown | Created in earlier sessions |
| Beta testing & first bug investigations | Unknown | `beta-test-wayland-x11/` and `wayland-bugs/` docs |
| Mode switcher bug investigation & fixes | Claude (claude-4.6-opus-high-thinking) | Current session — systematic SSH investigation, root cause analysis, all code fixes |
| Final verification & cleanup | Claude (claude-4.6-opus-high-thinking) | Current session — roundtrip testing documentation, prefix-match fix, grep fixes, DISPLAY hardening, Phase 2 poweroff |

---

## What Worked Well

- **Systematic step-by-step investigation** — Documenting every SSH snapshot during the fresh install walkthrough (docs #00–#14) made the precision mismatch root cause undeniable
- **Two-layer defense** — `crt-launcher.sh` (runtime sync) + Layer 2 in `02_hd_output_selection.sh` (backup-time sync) ensures the correct precision survives across all code paths
- **Dual-boot gating** — All new logic is gated behind `/boot/crt/linux` existence checks, so single-boot X11 systems are completely unaffected

## What Did Not Work Well

- **Modifying the live Batocera system during debugging** — Multiple rounds of "fix, test, break, fix" on the same machine produced false positives and wasted time. The directive to stop touching the machine and only read logs was the turning point.
- **Trusting CLI command names without verification** — `getCurrentMode` vs `currentMode` cost an entire debug cycle. Should have verified the CLI interface first.
- **Initial plan assumptions** — The overlay-only approach was architecturally impossible. More upfront research on the actual v43 build contents would have prevented the wrong starting direction.
