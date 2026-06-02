# FinalBurn Neo + Neo Geo - autoconfig spec (vanilla vertical)

## Config paths (Batocera)

| Layer | Path |
|-------|------|
| RetroArch per-core / per-content | `/userdata/system/configs/retroarch/config/FinalBurn Neo/` |
| Core options | `*.opt` alongside `.cfg` in same folder |
| System keys | `/userdata/system/batocera.conf` prefixes `fbneo.`, `neogeo.` (system name may be `fbneo` or `neogeo` depending on ROM folder; script must treat both if both exist in library) |

**Core display name:** `FinalBurn Neo` (space, matches `.info` / RetroArch content dir).

## Recommended `batocera.conf` interactions (vanilla)

1. **Respect existing cabinet policy.** Example from a live vertical test box: `fbneo.video_allow_rotate=off` (global). The autoconfig script must **not** delete unrelated `fbneo.*` lines; only **merge** keys it owns (documented list) or append if missing.

2. **`videomode`:** default can follow global `videomode` or per-system `fbneo.videomode=` **only** if the CRT catalog supports a single arcade timing; many cabinets instead rely on **`mame.switchres=1`** for arcade and leave FBNeo on `default`. **Script decision TBD:** either (A) no default `fbneo.videomode` in v1, or (B) match PCE-style explicit mode only after `listModes` proves a safe default.

3. **Per-ROM files:** generate `ROMNAME.cfg` / `ROMNAME.opt` **only** from an explicit manifest (JSON or tab-separated) shipped with CRT Script. Empty manifest = no FBNeo file writes.

## Advanced reference (not default for vanilla script)

CV1000 **SaiDaiOuJou** on a **Myzar** hybrid stack used **FBNeo-specific** `batocera.conf` lines, per-game `FinalBurn Neo/*.cfg`, and **Sai-only** X11 rotation coordination with MAME. Full recipe:  
`2026-05-21_crt-myzar-dp-hybrid-switchres/debug/ddpsdoj-saidaioujou-known-good.md`  
**Do not** auto-apply that stack on vanilla DP builds; keep as optional documented preset row if manifest says `myzar-sai-compat`.

## Validation targets for script

- [ ] Launch a vertical FBNeo title from user manifest: geometry correct with `display.rotate=1` on vanilla.
- [ ] Confirm **no** accidental edits under `Beetle PCE Fast/` or **`vectrex/`** when running “FBNeo-only” preset mode (if script supports subsystem filters).
- [ ] `grep fbneo /userdata/system/batocera.conf` before/after: only expected delta.

## See also

- [vectrex-vertical-autoconfig.md](vectrex-vertical-autoconfig.md) (same script family; **`vectrex.*`** only).
- [saturn-vertical-autoconfig.md](saturn-vertical-autoconfig.md), [dreamcast-vertical-autoconfig.md](dreamcast-vertical-autoconfig.md), [naomi-vertical-autoconfig.md](naomi-vertical-autoconfig.md), [psx-vertical-autoconfig.md](psx-vertical-autoconfig.md): non-geometry-class specs (state-injection / rotation-only / rotation + fill + custom viewport).
