# Design -- CRT EmulationStation Theme for 320x240

## Architecture

### Theme Engine (ES internals)

```
EmulationStation Boot
  └─ ThemeData.cpp loads theme.xml
      ├─ Evaluates ${screen.width}, ${screen.height}, ${screen.ratio}
      ├─ Evaluates tinyScreen boolean (width OR height <= 480)
      ├─ Processes subset selections from user settings
      ├─ Evaluates if="" conditionals on all elements
      └─ Renders views using normalized 0-1 coordinates
```

### Resolution Detection Flow

```
ES starts → SDL creates window → Renderer.cpp reads screen size
  ├─ screen.width = 320 (float)
  ├─ screen.height = 240 (float)
  ├─ screen.ratio = "4/3"
  ├─ isSmallScreen() = true (height <= 480)
  └─ Theme variables populated → XML conditionals evaluated
```

### Theme Variant Strategy (Option A: Carbon Fork)

```
es-theme-carbon-crt/
├── theme.xml                  # Root: includes CRT subset
├── views/
│   ├── common.xml             # Shared header (enlarged logos, no shadow)
│   ├── system.xml             # System carousel (large text, simple)
│   ├── basic.xml              # Text list (large font, high contrast)
│   ├── detailed.xml           # Simplified detail view
│   ├── screen.xml             # Status bar (minimal or hidden)
│   └── menu.xml               # Settings menu (large text)
├── layouts/
│   └── crt240p.xml            # Core 240p overrides
├── subsets/
│   ├── colorsets/             # High-contrast CRT color schemes
│   └── crtmode/               # 240p vs 480p variant selector
├── art/
│   ├── fonts/                 # Same TTF files (vector, scale-independent)
│   ├── logos/                 # SVG logos (scale to any resolution)
│   ├── bg-crt.png             # 320x240 background
│   └── (minimal other art)
└── lang/                      # Inherited from Carbon
```

### Key Design Decisions

1. **Fork, not patch**: Separate theme allows independent versioning and doesn't require upstream Carbon changes

2. **tinyScreen is already true at 320x240**: ES will set `isSmallScreen()` for any resolution where width or height <= 480, so we get `tinyScreen=true` for free. We can use this plus `if="${screen.height} <= 240"` for 240p-specific overrides vs 480p.

3. **Dual-resolution support (240p + 480p)**: Theme should work at both 320x240 and 640x480 since CRT users may run ES at either resolution depending on their CRT capabilities.

4. **4:3 native layout**: No widescreen detection needed. The `${screen.ratio}` will be "4/3" on CRT. Layout should be designed 4:3-first.

5. **Text-centric design**: At 240p, bitmap art wastes pixels. Prioritize readable text and clean vector logos over detailed artwork.

### Font Size Reference

| Target px at 240p | Normalized (0-1) | Use case |
|---|---|---|
| 16px | 0.067 | Primary headings |
| 14px | 0.058 | System names, game titles |
| 12px | 0.050 | Body text, metadata |
| 10px | 0.042 | Small labels (minimum readable) |
| 8px | 0.033 | Absolute minimum (avoid) |

For comparison, Carbon's default game list font is 0.030 (7.2px at 240p, unreadable).

### Image Asset Guidelines

| Asset type | Max dimensions | Format |
|---|---|---|
| System logos | 160x60 | SVG preferred, PNG fallback |
| Backgrounds | 320x240 | PNG or JPG (low-detail patterns) |
| Console art | 120x90 | PNG with alpha |
| Icons | 16x16 or 24x24 | SVG or PNG |
| Game media | 160x120 (thumbnail) | Scraped content, let ES scale |
