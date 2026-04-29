# PR Status — CRT Mode Switcher: NAS Gamelist Visibility Fix

## PR #390 (v42 — crt-hd-mode-switcher)

| Field | Value |
|-------|-------|
| Repo | ZFEbHVUE/Batocera-CRT-Script |
| PR | [#390](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/390) |
| Branch | `net-terminal-gene:crt-hd-mode-switcher` → `main` |
| Title | Add HD/CRT Mode Switcher with persistent display configuration |
| Status | **OPEN (Draft)** |
| Created | 2026-01-26 |

### Fix Status

NAS gamelist visibility fix pushed and tested on 2026-04-11. Confirmed working:
- CRT → HD: only mode_switcher visible in ES
- HD → CRT: all tools visible in ES
- Files no longer deleted on mode switch

---

## PR #395 (v43 — crt-hd-mode-switcher-v43)

| Field | Value |
|-------|-------|
| Repo | ZFEbHVUE/Batocera-CRT-Script |
| PR | [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) |
| Branch | `net-terminal-gene:crt-hd-mode-switcher-v43` → `main` |
| Title | Add Wayland/X11 dual-boot support with HD↔CRT mode switching |
| Status | **OPEN (Draft)** |
| Created | 2026-02-22 |

### Fix Status

Same NAS gamelist visibility fix applied to v43 branch on 2026-04-11. **Validated on hardware 2026-04-16** (PC X11 + Steam Deck Wayland/X11) alongside commit `64b9a16` mode-switcher fixes.

## Outstanding Items

- [x] Test v43 branch fix on Batocera v43 hardware (PR #395)
- [ ] Promote both PRs from Draft when review-ready
