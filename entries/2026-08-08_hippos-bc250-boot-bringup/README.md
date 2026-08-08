# HippOS BC-250 boot bring-up

**Session:** `2026-08-08_hippos-bc250-boot-bringup`
**Status:** FIXED (live disk) — EmulationStation on screen
**Primary repo:** hippos-linux (live image edits; no upstream PR yet)
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

HippOS `0.5.3-dev.3` on an AMD BC-250 looked stuck (ACPI/RDSEED/amdgpu noise, black screen, no SSH, dead keyboard). Bring-up proved the kernel and console path were fine; systemd + wait-online / remote-fs style stalls plus stock GRUB (`quiet`, wrong kernel emphasis) hid progress. Live EFI/rootfs edits got a debug shell with SSH, then a graphical LTS+amdgpu boot to EmulationStation on DisplayPort-0 @ 1920×1080.

## Where to look

| File / folder | Purpose |
|---------------|---------|
| [plan.md](plan.md) | Problem, approach, validation |
| [VERDICT.md](VERDICT.md) | Outcome + full change inventory |
| [research/01-exact-live-disk-changes.md](research/01-exact-live-disk-changes.md) | **Exact files/contents changed on the drive** |
| [research/02-live-disk-caveats.md](research/02-live-disk-caveats.md) | Recovery disk: what may be broken/degraded |
| [research/README.md](research/) | Findings index |
| [design/README.md](design/) | Live proof boot path |
| [design/proposed-flash-boot-flow.md](design/proposed-flash-boot-flow.md) | **Upstream ask:** dual-kernel GRUB + fresh-flash UX |
| [debug/README.md](debug/) | Commands / failure signs |
| [pr-status.md](pr-status.md) | PR tracking (none yet) |
