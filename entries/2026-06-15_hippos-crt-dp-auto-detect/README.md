# HippOS CRT — manual setup, pipeline fixes, ES UX

**Session:** `2026-06-15_hippos-crt-dp-auto-detect`
**Status:** TBD — Phase 1 done; Phases 2–3 pending
**Primary repo:** [hippos-linux/hippos-linux](https://github.com/hippos-linux/hippos-linux) (+ `hippos-emulationstation` for ES UI)
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

One development loop for HippOS CRT on DP + DAC (and general CRT use):

1. **Diagnosis** — `crt.enabled=auto` skips DisplayPort; boot pipeline runs CRT setup too late; switchres segfaults.
2. **Workaround validated (2026-06-15)** — `crt.enabled=true` + `hippos-crt-setup` + reboot → `641x480i` @ 15.78 kHz, ES readable on `hippos.local`.
3. **Pipeline fixes (TBD)** — pre-X crt-setup, skip `xrandr --auto`, switchres fix.
4. **ES enhancement (TBD)** — manual **System Settings → CRT** section (Enable, Video Output, Profile, Boot Resolution); deprecate auto as primary path.

Auto-detect cannot identify DAC or CRT-vs-HD on DisplayPort; manual user choice matches Batocera CRT Script philosophy.

## Where to look

| File / folder | Purpose |
|---------------|---------|
| [plan.md](plan.md) | Three phases, validation checklists, files to touch |
| [design/crt-boot-flow.md](design/crt-boot-flow.md) | Current vs intended boot pipeline, gaps |
| [design/crt-es-settings-proposal.md](design/crt-es-settings-proposal.md) | Recommended ES CRT menu (Mikey → maintainer) |
| [research/auto-detect-limits.md](research/auto-detect-limits.md) | Why auto/DAC detection fails |
| [debug/01-workaround-validated.md](debug/01-workaround-validated.md) | Phase 1 hardware validation |
| [code-changes/](code-changes/) | Implementation snippets (reference) |
| [design/test-plan.md](design/test-plan.md) | Rsync deploy, reset, acceptance tests |
| [VERDICT.md](VERDICT.md) | Close when Phases 2–3 ship or scope is cut |
