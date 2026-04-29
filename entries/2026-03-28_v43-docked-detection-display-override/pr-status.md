# PR Status — v43 Docked Detection Display Override

## CRT Script: DRM Name Fix

| Field | Value |
|-------|-------|
| Repo | ZFEbHVUE/Batocera-CRT-Script |
| PR | [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) (draft, includes this commit) |
| Branch | `crt-hd-mode-switcher-v43` |
| Commit | `1c01262` -- Fix DRM-to-xrandr output name mismatch in HD output selection |
| Status | **OPEN (Draft)** |
| Pushed | 2026-04-02 |

## Upstream: Docked Detection Fix

**MERGED to batocera.linux.** The docked detection logic inversion (skip detection when any output is explicitly configured) is now deployed in upstream.

## Tracking

- [x] Watch for dmanlfc to push fix branch to `batocera-linux/batocera.linux` — MERGED
- [x] Once merged to upstream, sync into CRT Script `main` and `crt-hd-mode-switcher-v43`
- [x] CRT Script DRM name fix: committed `1c01262` on `crt-hd-mode-switcher-v43` (April 2, 2026)
