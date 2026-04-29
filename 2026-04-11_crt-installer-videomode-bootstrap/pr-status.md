# PR Status - CRT Installer: Bootstrap global.videooutput, global.videomode, es.resolution

## PR #395 (MERGED 2026-04-23)

|| Field | Value |
||-------|-------|
|| Repo | ZFEbHVUE/Batocera-CRT-Script |
|| PR | [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) |
|| Branch | `crt-hd-mode-switcher-v43` → `main` |
|| Status | **MERGED** (2026-04-23) |

Changes implemented in both `Batocera-CRT-Script-v42.sh` (Inserts A/B/C at lines ~4301/4350/4370) and `Batocera-CRT-Script-v43.sh` (Inserts A/B/C at lines ~5333/5380/5402).

- **Insert A:** Capture HD baseline, derive boot mode key from videomodes.conf
- **Insert B:** Write `global.videomode`/`global.videooutput` to batocera.conf; pre-seed backup dirs
- **Insert C:** Fix `es.resolution` to use correct videomodes.conf key (not WxH.rate.00000)

See `VERDICT.md` for full testing details.

## Completed

- [x] ES Video Mode shows correct Boot_ entry after first CRT boot
- [x] `global.videooutput` persists in batocera.conf
- [x] Mode switcher backup dirs pre-seeded with correct format
- [x] CRT → HD → CRT roundtrip works
- [x] Merged in PR #395
