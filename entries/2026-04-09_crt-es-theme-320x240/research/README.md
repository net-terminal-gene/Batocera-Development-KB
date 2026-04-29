# Research -- CRT EmulationStation Theme for 320x240

## Findings

### 1. Theme Source and Packaging

Carbon (the default Batocera theme) lives in an external GitHub repo:
- **Repo:** https://github.com/fabricecaruso/es-theme-carbon
- **Pinned commit in batocera.linux:** `507eb2c025fb51277166dfedbb493b8ac576d14c`
- **Build recipe:** `batocera.linux/package/batocera/emulationstation/es-theme-carbon/es-theme-carbon.mk`
- **Install path:** `/usr/share/emulationstation/themes/es-theme-carbon/`
- **User themes path:** `/userdata/themes/`

Themes are NOT compiled. They are pure XML + assets, copied as-is to the target. A custom theme can be placed in `/userdata/themes/<name>/` and selected from ES UI.

### 2. EmulationStation Theme Specification

The authoritative theme spec is `THEMES.md` in `batocera-linux/batocera-emulationstation`:
- **ES version:** `7d66e25fa44fa42b664892af2198aeef20d86152`
- **Format version:** 7 (current for batocera-emulationstation)
- **Key file:** `es-core/src/ThemeData.cpp` (parses theme XML)

#### Available theme variables (set by ES, read-only in theme XML):
- `${screen.width}` (float)
- `${screen.height}` (float)
- `${screen.ratio}` (string, e.g. "4/3", "16/9")
- `${screen.vertical}` (bool)
- `${system.theme}` (current system folder name)

#### Conditional attributes on any XML element:
- `tinyScreen="true|false"` -- ES boolean, true when width or height <= 480
- `if="<expression>"` -- arbitrary expression, e.g. `if="${screen.height} <= 240"`
- `ifArch="<archlist>"` -- platform filter
- `ifSubset="<subset>:<value>"` -- subset-conditional
- `ifHelpPrompts="true|false"` -- help visibility
- `lang="<langcode>"` -- language filter

#### Subset system:
Themes can define user-selectable options (subsets). Each subset presents named choices in ES Settings. Example:
```xml
<subset name="crtmode" displayName="CRT Resolution">
    <include name="240p">./layouts/crt240p.xml</include>
    <include name="480p">./layouts/crt480p.xml</include>
</subset>
```

### 3. Carbon Theme Structure (Current)

```
es-theme-carbon/
├── theme.xml           # Root (16.3 KB) -- all includes, subsets, variables
├── views/              # View layout XMLs (basic, detailed, grid, tiles, etc.)
├── layouts/            # Resolution/platform-specific overrides
│   └── gpicase.xml     # The only low-res layout (tinyScreen=true)
├── subsets/            # ~20 user-configurable option modules
│   ├── colorsets/      # 8 color schemes
│   ├── systemview/     # 9 system view variants
│   └── ...
├── art/
│   ├── fonts/          # Cabin-Bold.ttf, Cabin-Regular.ttf, players.ttf
│   ├── logos/          # Per-system SVG/PNG (with language variants)
│   ├── controllers/    # Per-system controller SVGs
│   ├── consoles/       # Per-system console PNGs
│   ├── background/     # Per-system background JPGs
│   └── (UI chrome PNGs/SVGs)
├── lang/               # i18n XMLs
└── games/              # Per-system game metadata overrides
```

### 4. Carbon's gpicase.xml Analysis

The only existing low-res support in Carbon. Key changes from default:

**Font increases:**
- Game list: 0.030 -> 0.044 (+47%)
- Grid labels: 0.026 -> 0.039 (+50%)
- Help text: 0.025 -> 0.044 (+76%)
- System info: 0.024 -> 0.048 (+100%)

**Layout simplifications:**
- Grid: `gridSize` set to `1 1` (single item visible)
- Decorative frames: hidden via `<path>00000000</path>`
- Shadows: removed
- Blur effects: disabled
- Animated elements: disabled
- Glow selection: disabled

**What gpicase.xml does NOT address (gaps for CRT):**
- No 4:3 aspect ratio adjustments (GPi is also 4:3, so this may be fine)
- No CRT-specific color/contrast considerations
- Background images still reference full-res assets
- System logos still use standard Carbon logos (may be too detailed at 240p)
- No consideration for CRT viewing distance (GPi is handheld, CRT is across the room)

### 5. tinyScreen Threshold

From `batocera-emulationstation` source (`Renderer.cpp` / `ScreenSettings`):
- `isSmallScreen()` returns true when screen width OR height <= 480
- This means 320x240 AND 640x480 both trigger `tinyScreen=true`
- At 640x480, height = 480 (exactly at threshold, still true)
- At 800x600, height = 600 (tinyScreen = false)

[Inference] If we want to differentiate between 240p and 480p in the theme, we cannot rely on `tinyScreen` alone. We would need `if="${screen.height} <= 240"` for 240p-specific overrides.

### 6. Deployment Options

**For development/testing:**
1. Create theme directory locally
2. SCP/rsync to `/userdata/themes/es-theme-carbon-crt/` on Batocera device
3. Select in ES: System Settings -> Theme

**For distribution (later):**
- Host on GitHub as a standalone theme repo
- Add to Batocera's themes.json feed (requires approval)
- Or distribute via CRT Script installer

### 7. Mikey's Existing Custom Themes on Device

Four themes installed in `/userdata/themes/`:

| Theme | Description | Size |
|-------|-------------|------|
| `es-theme-carbon-hd` | **Straight copy of stock Carbon** + custom system artwork added | 195 MB |
| `es-theme-carbon` | **Overlay-only**: just `art/logos/CRT.svg` + `art/consoles/CRT.png` (merges with system Carbon) | ~2 files |
| `es-theme-carbon Retro` | Another Carbon variant (standard structure) | — |
| `AI-HYPERTOCERA-THE-MINI-CAKE-TV` | Separate theme (has `custom logo/` dir, `splash/` dir) | — |

**`es-theme-carbon-hd` custom additions** (files NOT in stock system Carbon):

Logos added:
- `art/logos/CRT.svg` -- CRT system logo
- `art/logos/batoparrot.svg`, `art/logos/batoparrot-w.svg` -- BatoParrot system
- `art/logos/winpopcap.svg` -- Windows PopCap games
- `art/logos/winbigfish.svg` -- Windows Big Fish games
- `art/logos/wingamehouse.svg` -- Windows GameHouse games

Console art added:
- `art/consoles/CRT.png`
- `art/consoles/teknoparrot.png`

Controller art added:
- `art/controllers/teknoparrot.svg`

Backgrounds added:
- `art/background/batoparrot.jpg`
- `art/background/teknoparrot.jpg`
- `art/background/winbigfish.jpg`
- `art/background/wingamehouse.jpg`
- `art/background/winpopcap.jpg`

**`theme.xml` is identical** to the system-installed Carbon (zero diff). The HD theme is just a straight copy of stock Carbon with custom artwork dropped in for systems that don't exist in upstream Carbon. No XML or settings modifications.

The `global.theme` setting is empty (no explicit override), meaning ES uses its default theme selection.

**Implication for CRT 240p theme:** The base for the CRT theme is upstream es-theme-carbon. Mikey's custom system artwork (CRT, BatoParrot, PopCap, BigFish, GameHouse, TeknoParrot) should be carried over into the new CRT theme as an additional step, but the fork point is stock Carbon, not the HD copy.

### 8. ES Overlay Theme Behavior

The `/userdata/themes/es-theme-carbon/` directory contains only two files (`CRT.svg` logo and `CRT.png` console). ES checks `/userdata/themes/` before `/usr/share/emulationstation/themes/`, and when a theme in `/userdata/themes/` has the same name as a system theme, ES uses the user copy as an overlay. This means those two CRT assets get merged into the stock Carbon theme for CRT mode.

[Inference] This overlay pattern could also be used for the CRT 240p theme: keep the full theme in one location and only override what's needed. However, for a 240p theme, the XML changes are substantial enough that a full standalone copy is more maintainable.

### 9. Vault Cross-References

From the Vault, the following existing pages are relevant:
- `wiki/entities/emulationstation.md` -- notes "320x240 boot | Not officially supported -- ES themes don't support it"
- `wiki/concepts/batocera-themes.md` -- theme structure, installation, development overview
- `wiki/concepts/crt-x11-stack.md` -- mode IDs like `640x480.60000:320x240`
- `raw/crt-script-wiki/CRT-Tools-Guide.md` -- "640x480 grid" and "320x240@60Hz (not recommended)"
- `raw/crt-script-wiki/Emulation-Station-scaling-and-centering.md` -- ES at 640x480

The Vault explicitly notes that 320x240 for ES UI is "not officially supported" due to theme limitations. This project aims to change that.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

