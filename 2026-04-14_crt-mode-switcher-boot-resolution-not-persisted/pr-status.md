# PR Status — CRT Mode Switcher: Boot Resolution Persistence

## PR #395

| Field | Value |
|-------|-------|
| Repo | ZFEbHVUE/Batocera-CRT-Script |
| PR | [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) |
| Branch | `crt-hd-mode-switcher-v43` |
| Status | **OPEN Draft** |

## Session status

**VERDICT:** FIXED (see `VERDICT.md`). Root causes: truncated `video_mode.txt`, stale "preserve existing" guard, missing `es_resolution.txt` backup path; shim Wayland detection and labwc rule cleanup.

**Also shipped in `64b9a16` (2026-04-16):** `02_hd_output_selection.sh` continues to write `es_resolution.txt` with boot selection; HD restore no longer kills ES mid-switch (see `../2026-04-13_crt-mode-switcher-wayland-blank-screen/debug/x11/04-hd-restore-killall-es-regression.md`).
