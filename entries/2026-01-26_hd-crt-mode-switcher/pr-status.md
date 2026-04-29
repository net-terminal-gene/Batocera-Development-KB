# PR Status - HD/CRT Mode Switcher

## PR #390 (merged into v42)

|| Field | Value |
||-------|-------|
|| Repo | ZFEbHVUE/Batocera-CRT-Script |
|| PR | [#390](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/390) |
|| Branch | `crt-hd-mode-switcher` → `main` |
|| Title | Add HD/CRT Mode Switcher with persistent display configuration |
|| Status | **MERGED** (v42, Apr 2026) |
|| Created | 2026-01-26 |

## Review Comments

### 1. Backup path (net-terminal-gene, 2026-01-26)

**File:** `Batocera-CRT-Script-v42.sh` (mode backup directory creation)

**Comment:** "Backups need to put into `/userdata/Batocera-CRT-Script-Backup/mode_backups/`"

**Status:** Addressed - backup paths updated from `/userdata/system/Batocera-CRT-Script/mode_backups/` to `/userdata/Batocera-CRT-Script-Backup/mode_backups/`.

---

## v43 Supercedes (PR #395)

PR #395 (`crt-hd-mode-switcher-v43`) builds on top of PR #390, adding Wayland/X11 dual-boot support for v43 Steam Deck. PR #395 **merged on 2026-04-23** and includes the full `crt-hd-mode-switcher` architecture plus v43 Wayland/X11 architecture.

See: [`2026-02-22_v43-wayland-x11-dual-boot/`](../2026-02-22_v43-wayland-x11-dual-boot/)

## Outstanding Items

- [x] v42 mode switcher (MERGED in v42)
- [x] v43 Wayland/X11 dual-boot (MERGED in v43 via PR #395)
- [ ] NVIDIA GPU testing on v43 (future session)
