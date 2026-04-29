# CRT EmulationStation Theme for 320x240

## Agent/Model Scope

Composer + explore agents for research. SSH-batocera for on-device testing once theme is ready.

## Problem

No EmulationStation theme natively supports 320x240 CRT resolutions. The lowest resolution any theme targets is 640x480 (via GPi Case `tinyScreen` layouts in Carbon). When running ES at 320x240 on a CRT, text is unreadable (fonts render at 3-4px), UI elements overlap, and the interface is unusable.

CRT users running Batocera at native 240p need a theme (or theme variant) specifically designed for this resolution.

## Root Cause

ES themes use normalized 0-1 coordinates, so they technically scale to any resolution. But font sizes designed for 1080p (e.g., `fontSize: 0.016` = 17px at 1080p) become ~3.8px at 240p. The existing `tinyScreen` / `gpicase.xml` layout in Carbon was designed for GPi Case (320x240 handheld with tiny physical screen), but its adjustments may not be sufficient or appropriate for a CRT display where the physical screen is large but the pixel count is low.

## Approach Options

### Option A: Fork upstream es-theme-carbon, add CRT 240p variant (RECOMMENDED)
- Clone upstream Carbon (`github.com/fabricecaruso/es-theme-carbon` at pinned commit `507eb2c`)
- Add a new subset option (e.g., "CRT 240p") alongside the existing "Optimize for small screens"
- Create `layouts/crt240p.xml` with CRT-optimized layout overrides
- Override font sizes, hide decorative elements, simplify views
- Leverage `if="${screen.height} <= 240"` or `tinyScreen="true"` conditionals
- Copy in Mikey's custom system artwork (CRT, BatoParrot, PopCap, BigFish, GameHouse, TeknoParrot) as a separate step
- Deploy to `/userdata/themes/es-theme-carbon-crt/`

### Option B: Create standalone minimal CRT theme from scratch
- New theme targeting 320x240 and 640x480 CRT resolutions
- Minimal design: large text, simple backgrounds, no heavy art
- 4:3 aspect ratio native layout
- Optimized for readability on CRT phosphor displays

### Option C: Patch Carbon's gpicase.xml for CRT use
- Modify the existing `tinyScreen` pathway
- Least effort but most constrained; GPi Case layout may not translate well to CRT

**Recommended: Option A** -- Fork upstream Carbon, add CRT 240p variant. This gives us the full Carbon feature set as a baseline and lets us progressively override what doesn't work at 240p. Mikey's custom system artwork (CRT, BatoParrot, PopCap, BigFish, GameHouse, TeknoParrot) gets copied in separately since the HD theme is just a straight copy of Carbon with those assets added.

## Key Technical Findings

### Where themes live
- **Build system:** `batocera.linux/package/batocera/emulationstation/es-theme-carbon/`
- **Source repo:** `https://github.com/fabricecaruso/es-theme-carbon` (external GitHub)
- **On-device:** `/usr/share/emulationstation/themes/es-theme-carbon/` (system) or `/userdata/themes/<name>/` (user-installed)
- **Theme spec:** `THEMES.md` in `batocera-linux/batocera-emulationstation` repo

### How ES handles resolution
- All coordinates are normalized 0-1 (fraction of screen width/height)
- Theme variables: `${screen.width}`, `${screen.height}`, `${screen.ratio}`
- `tinyScreen` boolean: ES sets this when width OR height <= 480 (from `Renderer::isSmallScreen()`)
- `if=` attribute: arbitrary expression evaluation against theme variables
- Subsets: user-selectable theme variants in ES settings menu

### Carbon's existing low-res support
- `layouts/gpicase.xml`: loaded via `tinyScreen="true"` subset "Optimize for small screens"
- Increases fonts to 0.039-0.048 range (9-12px at 240p)
- Hides decorative elements, simplifies grid to single item
- Disables blur, glow, animations, round borders
- Still may not be ideal for CRT (designed for 2.8" handheld LCD)

### What needs CRT-specific treatment
- Font sizes: must be 0.05+ to be readable at 240p on a CRT (12+ pixels)
- Images: all backgrounds/logos need 320x240 or smaller variants
- Layout: 4:3 native, no widescreen assumptions
- System logos: SVG preferred (scales cleanly), or pre-rendered at 320px wide
- Color: high contrast for CRT phosphors (bright text on dark, or vice versa)
- Grid views: 1-2 items max, or text-only list
- Status bar: simplified (clock, battery can be removed for CRT desktop)

## Approach Pivot (2026-04-11)

Original plan was Option A (standalone fork deployed to `/userdata/themes/es-theme-carbon-crt/`). **Distribution approach changed:** instead of a standalone theme repo, `crt240p.xml` and a `theme.xml` subset block are patched directly into the stock Carbon theme (`/usr/share/emulationstation/themes/es-theme-carbon/`) during CRT Script installation.

Key decisions:
- No `tinyScreen` gate -- subset is available at all resolutions
- Auto-enables (`on`) when user selects `320x240@60` as EDID boot resolution; `off` otherwise
- Stock `theme.xml` backed up via `FILES_TO_HANDLE` before patching; `restore_all()` recovers it
- `crt240p.xml` added to `EXTRA_DELETE_FILES` so restore removes it cleanly
- Dev theme repos (`es-theme-carbon-crt`, `es-theme-carbon-hd`) used for iteration; deployed to stock theme once finalized
- `batocera-save-overlay` called after patching (already present later in install flow)

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Geometry_modeline/crt240p.xml` | New -- CRT 240p layout source asset for installer |
| Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script-v42.sh` | Copy crt240p.xml, inject subset block, write es_settings.cfg preference, backup/restore arrays |
| Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` | Same changes as v42 |
| es-theme-carbon-crt (dev) | `layouts/crt240p.xml` | CRT 240p layout -- font sizes and positions tuned for 320x240 on 15kHz CRT |
| es-theme-carbon-crt (dev) | `theme.xml` | Added crt240p subset block after optimizesmallscreens |

## Validation

- [ ] Theme renders correctly at 320x240 on CRT (Philips 20PT6341/37)
- [ ] All text is readable at normal CRT viewing distance (~3-6 feet)
- [ ] System list navigable with controller
- [ ] Game list navigable with controller
- [ ] No UI element overlap or clipping
- [ ] Theme also works at 640x480 (tested with crt240p off)
- [ ] Font rendering clean (no sub-pixel artifacts on CRT)
- [ ] Performance acceptable (no lag on BC-250)
- [ ] Restore correctly reverts theme.xml and removes crt240p.xml
- [ ] Auto-enable logic correct: on at 320x240, off at all other resolutions

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

