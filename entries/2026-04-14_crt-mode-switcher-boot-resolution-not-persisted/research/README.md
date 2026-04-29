# Research — CRT Boot Resolution Persistence

## Evidence from Device

**CRT backup's `batocera.conf`:**
- `es.resolution=769x576.50.00060` (correct full precision, from bootstrap fix)
- `global.videomode=769x576.50.00` (truncated)

**CRT backup's `video_mode.txt`:**
- `global.videomode=769x576.50.00` (truncated)

**Live `batocera.conf` after HD->CRT restore:**
- `es.resolution=769x576.50.00` (truncated -- WRONG, was overwritten by restore_video_settings)

**`batocera-resolution currentMode` in CRT/X11 mode:** returns empty

## Why `global.videomode` is Truncated

`batocera-resolution currentMode` returns empty in X11/CRT mode. The backup fallback greps `batocera.conf` for `^global.videomode`, which already has the truncated value. The truncation origin is unknown (possibly set by ES or batocera-resolution during runtime), but the bootstrap fix only set `es.resolution` with full precision, not `global.videomode`.

## The Overwrite Chain

1. `restore_mode_files "crt"` restores full `batocera.conf` (line 1177-1181) -- `es.resolution=769x576.50.00060` is correct at this point
2. `restore_video_settings "crt"` runs AFTER (line 1330)
3. Reads `video_mode.txt` -> `global.videomode=769x576.50.00` (truncated)
4. Derives `mode_id=769x576.50.00`
5. Overwrites `es.resolution=769x576.50.00` in both batocera.conf and batocera-boot.conf
6. Full-precision value from step 1 is lost

## Relation to Other KB Entries

- `2026-04-08_crt-mode-switcher-truncated-videomode`: Same truncation root cause. That entry identified the problem in `02_hd_output_selection.sh`'s "preserve existing" guard. This entry identifies it in the `restore_video_settings` overwrite path.
- `2026-04-11_crt-installer-videomode-bootstrap`: Fixed the install-time path. The install correctly writes `es.resolution` with full precision. But the mode switcher restore clobbers it.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

