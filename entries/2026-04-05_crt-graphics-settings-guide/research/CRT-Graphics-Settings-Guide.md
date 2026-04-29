# CRT Graphics Settings Guide for Modern PC Games

Optimized graphics settings for playing modern PC games on CRT televisions via Batocera-CRT-Script with Steam (HD Mode).

## Hardware Context

| Component | Details |
|-----------|---------|
| **APU** | AMD BC-250 (Cyan Skillfish) — 6x Zen 2 cores, 24 RDNA 2 CUs, 16 GB GDDR6 |
| **GPU Class** | Comparable to RX 6600 / GTX 1660 Ti |
| **CRT Displays** | Philips 20PT6341/37 (20" slot mask, 15 kHz, component) / Sony KV-9PT40 (9" Trinitron aperture grille, 15 kHz, composite) |
| **Native CRT Resolutions** | 240p, 480i |
| **HD Mode Output** | Up to 1920x1080 @ 60 Hz (auto-detected via xrandr/EDID) |
| **Ray Tracing** | Supported in hardware (RDNA 2) but impractical at CRT-class resolutions on this APU |

## How HD Mode Works with CRT-Script

When you switch to **HD Mode** via the mode switcher, CRT-Script:

1. Clears `global.videomode` and `es.resolution` from `batocera.conf`
2. Lets Batocera auto-detect the best mode from your connected display's EDID
3. Prefers **1920x1080 @ 60 Hz** if available; otherwise picks the largest mode ≥ 59 Hz
4. Steam games run at whatever the desktop resolution is, or whatever the game's own resolution setting dictates

Your games render at the resolution you set **inside the game** (or via FSR upscaling), then the signal passes through your HDMI-to-component/composite chain to the CRT. The CRT itself is always displaying at its native scan rate (15 kHz horizontal, 480i/240p).

## Why CRT Changes Everything About Graphics Settings

### What the CRT gives you for free

CRT phosphor physics provide natural image processing that makes several GPU-expensive effects redundant:

| CRT Property | Effect | What it replaces |
|--------------|--------|-----------------|
| **Phosphor bloom & persistence** | Bright pixels bleed into neighbors, softening edges | Anti-aliasing |
| **Electron beam gaussian profile** | Each scanline has a soft falloff, not a hard pixel edge | Edge smoothing |
| **Analog signal bandwidth limiting** | High-frequency detail is naturally rolled off horizontally | Sharpening filters |
| **Interlace field blending (480i)** | Alternating fields blend temporally in your eye over ~16ms | Temporal anti-aliasing |
| **Phosphor dot pitch / slot mask** | Subpixel structure adds texture that masks aliasing artifacts | MSAA/FXAA |

### What the CRT cannot see

At 480i (effectively ~240 visible lines per field on a 20" screen), many effects that cost significant GPU time produce **no visible difference**:

- **High-resolution shadow maps** — shadow edges are already softened by the CRT's analog nature
- **Ultra-quality screen space reflections** — reflections in puddles/windows cannot resolve fine detail at 480 lines
- **High-resolution volumetric fog** — fog is by definition a soft, low-frequency effect; Low and Ultra look identical through 480i
- **Subsurface scattering quality** — skin translucency subtleties are invisible at this pixel density
- **Anisotropic filtering beyond 4x** — texture sharpness at oblique angles hits diminishing returns fast at 480 lines
- **Color precision (High vs Medium)** — banding differences are masked by CRT phosphor response curves
- **Mirror quality** — mirrors render a second viewport; at 480i the reflection cannot show detail worth the cost

### What still matters on CRT

- **Shadows ON vs OFF** — the presence/absence of shadows is clearly visible at any resolution; they provide depth and grounding
- **Ambient occlusion** — subtle darkening in crevices reads even at low res; the "flat" look without it is noticeable
- **Texture quality** — textures at Medium/High avoid obvious blurriness even on CRT; Low textures can look muddy
- **Draw distance / LOD** — pop-in is very noticeable on CRT because the eye tracks motion naturally on the analog display
- **Volumetric fog ON vs OFF** — atmospheric presence matters; just don't crank the resolution
- **Crowd density** — affects gameplay feel and immersion; visible even at 480i

---

## Universal CRT Base Settings

Apply these as a starting point for **any** modern PC game on CRT via HD Mode. Per-game tables below override where needed.

### Post-Processing & Camera Effects

| Setting | Recommendation | Rationale |
|---------|---------------|-----------|
| **Anti-Aliasing** | **Off** | CRT provides natural AA via phosphor bloom and beam profile. GPU AA is wasted work. |
| **Motion Blur** | **Off** | CRT phosphor persistence already creates natural motion blur. Stacking digital motion blur on top produces a muddy image. |
| **Film Grain** | **Off** | CRT phosphor dot structure and analog noise already add organic texture. Digital film grain at 480i just reduces clarity. |
| **Chromatic Aberration** | **Off** | Simulates a lens defect. CRT electron guns already produce real color fringing at convergence boundaries. Redundant. |
| **Depth of Field** | **Off or Low** | At 480i, the entire image is already soft relative to HD. Adding DoF blur on top loses too much detail. Off preferred. |
| **Lens Flare** | **Off** | Artistic choice, but costs GPU for an effect barely distinguishable from CRT bloom at this resolution. |
| **Vignette** | **Off** | CRT naturally darkens at screen edges due to beam deflection angle. Redundant. |
| **Sharpening** | **Off** | The CRT's analog bandwidth limiting means the signal is already at the display's resolving limit. Sharpening just amplifies noise. |

### Shadows

| Setting | Recommendation | Rationale |
|---------|---------------|-----------|
| **Shadow Quality** | **Low–Medium** | Shadows must exist for scene readability, but high-res shadow maps waste GPU at 480i. Low still provides clear directional shadows. |
| **Contact Shadows** | **Off** | Fine-detail close-range shadows invisible at CRT resolution. |
| **Cascaded Shadow Range** | **Medium** | Controls how far sun shadows extend. Medium covers the visible play area without wasting fillrate. |
| **Cascaded Shadow Resolution** | **Low** | Shadow detail on distant terrain is unresolvable at 480i. |
| **Distant Shadows** | **Low or Off** | Completely unresolvable at CRT pixel density. |

### Lighting & Reflections

| Setting | Recommendation | Rationale |
|---------|---------------|-----------|
| **Ambient Occlusion** | **Low–Medium** | Provides visible depth cues even at 480i. Ultra/High AO uses higher sample counts that produce no visible improvement on CRT. |
| **Screen Space Reflections** | **Off or Low** | The single most expensive non-RT setting in many games (~40% FPS cost at Ultra). At 480i, reflections cannot resolve enough detail to justify any quality above Low. Off is also fine. |
| **Local Lighting Quality** | **Medium** | Affects point light accuracy. Medium is sufficient for the resolving power of a 15 kHz display. |
| **Ray Tracing** | **Off** | RDNA 2 with 24 CUs can technically do RT, but the performance cost is severe and the visual payoff is invisible at 480i. Every RT feature (reflections, shadows, lighting, GI) should be off. |
| **Path Tracing** | **Off** | Requires RTX 4070 Ti+ class GPU for playable framerates even at 1080p. Not viable on BC-250. |

### Textures & Detail

| Setting | Recommendation | Rationale |
|---------|---------------|-----------|
| **Texture Quality** | **Medium–High** | Textures are sampled at render resolution, not display resolution. Medium avoids VRAM pressure (shared 16 GB GDDR6) while staying sharp enough. High if VRAM headroom allows. |
| **Anisotropic Filtering** | **4x** | Makes textures at oblique angles less blurry. 4x is the sweet spot; 8x/16x produce no visible improvement at 480i. Nearly free on RDNA 2. |
| **Level of Detail (LOD)** | **Medium–High** | Pop-in is very visible on CRT due to the eye's natural tracking on analog displays. Keep this at Medium minimum; High if FPS allows. |
| **Max Dynamic Decals** | **Low** | Bullet holes, blood spatters at fine detail — invisible at 480i. |

### Atmosphere & Effects

| Setting | Recommendation | Rationale |
|---------|---------------|-----------|
| **Volumetric Fog** | **Low** | Fog is a soft, low-frequency effect. Low quality fog looks nearly identical to Ultra through 480i. Saves 10–12% FPS. |
| **Volumetric Clouds** | **Low–Medium** | Same reasoning as fog. Clouds are soft by nature. |
| **Particle Effects** | **Medium** | Explosions, fire, sparks — visible at any resolution. Medium density sufficient. |

### Upscaling & Performance

| Setting | Recommendation | Rationale |
|---------|---------------|-----------|
| **FSR 2.1 / Upscaling** | **Quality or Balanced** | FSR on RDNA 2 is well-optimized. Renders at lower internal resolution and upscales. At 480i output, even Balanced mode produces excellent results because the CRT's analog nature hides upscaling artifacts. |
| **FSR Image Sharpening** | **0** | FSR includes a post-upscale sharpening pass. Set to 0 for CRT. The display's analog bandwidth is already at its resolving limit — sharpening amplifies noise and edge artifacts that the CRT's natural softness would otherwise hide. |
| **Frame Generation** | **Off** | Not available on RDNA 2 (requires RDNA 3+ or RTX 40+). |
| **VSync** | **On** | Prevents screen tearing, which is especially visible on CRT due to the scanning electron beam. |
| **Resolution** | **720p or 1080p internal** | See notes below. |

### Resolution Strategy

Your game's internal render resolution and your CRT's display capability are independent:

1. **The game renders** at whatever resolution you set (720p, 1080p, etc.)
2. **The GPU/converter downscales** to the CRT's native capability (480i over component)
3. **The CRT displays** at 15 kHz / 480i

**Recommended approach:**
- Set game resolution to **720p (1280x720)** for maximum FPS headroom — the downscale to 480i is clean and the CRT cannot resolve the difference between 720p and 1080p input
- If FPS is comfortable at 720p, try **1080p** — some games have UI elements that scale better, and supersampling down to 480i acts as free AA
- Use **FSR Quality** if targeting 1080p output to get effective 720p render cost with 1080p UI scaling

### Crowd & World Density

| Setting | Recommendation | Rationale |
|---------|---------------|-----------|
| **Crowd Density** | **Medium** | Crowds are visible even at 480i and affect immersion. But High/Ultra crowds stress CPU and the BC-250's 6 Zen 2 cores. Medium is the sweet spot. |
| **Draw Distance** | **Medium–High** | Open-world games benefit from seeing far. CRT won't resolve distant detail, but silhouettes and large structures are visible. |

---

## Cyberpunk 2077 — Complete CRT Settings

Every graphics setting in Cyberpunk 2077 (Update 2.1+), optimized for CRT output on BC-250.

### Quick Preset Starting Point

Start with the **Medium** preset, then apply the overrides below. Medium preset on BC-250 at 720p should yield 80–100+ FPS, giving headroom for the specific tweaks.

### Video / Display Settings

| Setting | Value | Notes |
|---------|-------|-------|
| **Resolution** | **1280x720** | Optimal for CRT. Try 1080p if FPS allows. |
| **Windowed Mode** | **Fullscreen** | Required for proper signal output. |
| **VSync** | **On** | Prevents tearing on CRT scanline display. |
| **Maximum FPS** | **60** | Match CRT vertical refresh. No benefit exceeding 60 on a 60 Hz display. |
| **HDR Mode** | **Off** | CRT is SDR. HDR processing wastes GPU cycles. |
| **NVIDIA Reflex** | **N/A** | AMD system — not available. |

### Resolution Scaling

| Setting | Value | Notes |
|---------|-------|-------|
| **AMD FSR 2.1** | **Quality** | Renders at ~75% resolution and upscales. At 720p output this means ~540p internal — perfectly adequate for 480i CRT. Free 25–30% FPS gain. If already at 720p and FPS is fine, try Off. |
| **AMD FSR 2.1 Image Sharpening** | **0** | FSR's built-in sharpening filter. Set to 0. The CRT's analog bandwidth is already at the display's resolving limit — sharpening amplifies noise and creates artifacts at 480i. The CRT's natural softness is a feature, not a defect. |
| **Frame Generation** | **Off** | Not available on RDNA 2 (requires RDNA 3+ or RTX 40+). |
| **DLSS** | **N/A** | AMD system — not available. |
| **Intel XeSS** | **N/A** | AMD system — not available. |
| **DLSS Frame Generation** | **N/A** | Not available on RDNA 2. |
| **DLSS Ray Reconstruction** | **N/A** | Not available on RDNA 2. |

### Basic / Post-Processing

| Setting | Value | Notes |
|---------|-------|-------|
| **Field of View** | **80–90** | Lower FOV = less to render = more FPS. 80 feels natural on a 4:3 CRT. Default 90 is fine too. |
| **Film Grain** | **Off** | CRT phosphors add their own texture. Digital grain at 480i is noise. |
| **Chromatic Aberration** | **Off** | CRT convergence provides real chromatic effects. |
| **Depth of Field** | **Off** | 480i image is already soft. DoF on top loses too much. |
| **Lens Flare** | **Off** | Marginal visual payoff at 480i. Saves a small amount of GPU. |
| **Motion Blur** | **Off** | CRT phosphor persistence = natural motion blur. Digital motion blur stacks and smears. |

### Performance

| Setting | Value | Notes |
|---------|-------|-------|
| **Crowd Density** | **Medium** | Night City crowds are immersive but CPU-heavy. Medium keeps streets populated without starving the Zen 2 cores. |
| **HDD Mode** | **Off** | Unless running from a slow storage device. |
| **SMT** | **Auto** | Let the game decide — Auto is optimal for 6-core Zen 2. |

### Advanced Graphics — Shadows

| Setting | Value | Notes |
|---------|-------|-------|
| **Contact Shadows** | **Off** | Tiny close-range shadow detail. Invisible at 480i. |
| **Local Shadow Mesh Quality** | **Low** | Shadow casting mesh complexity — unresolvable detail at CRT resolution. |
| **Local Shadow Quality** | **Low** | Point light shadow detail. Low provides functional shadows without wasting fillrate. |
| **Cascaded Shadows Range** | **Medium** | How far sun shadows extend. Medium covers gameplay-relevant distance. |
| **Cascaded Shadows Resolution** | **Low** | Sun shadow detail. Low is visually indistinguishable from High at 480i. |
| **Distant Shadows Resolution** | **Off** | Far shadow detail — completely invisible on CRT. |

### Advanced Graphics — Lighting & Reflections

| Setting | Value | Notes |
|---------|-------|-------|
| **Ambient Occlusion** | **Medium** | Provides visible depth. The AO darkening in corners/crevices reads clearly even at 480i. Ultra just uses more samples for no visible gain. |
| **Screen Space Reflections Quality** | **Off** | Night City's wet streets look great with SSR, but this is the **single most expensive non-RT setting** (~40% FPS at Ultra vs Off). At 480i the reflections cannot resolve enough detail. Reclaim the massive FPS. |
| **Local Lighting Quality** | **Medium** | Point light precision — Medium sufficient for 15 kHz display. |
| **Color Precision** | **Medium** | Reduces color banding in gradients. CRT phosphor response curves naturally dither banding. Medium saves 5–6% FPS. |
| **Mirror Quality** | **Low** | Mirrors render a second viewport. At 480i the reflection is too low-res to justify the cost. |
| **Improved Facial Lighting Geometry** | **Off** | Enhanced facial light detail. At 480i, faces are ~20 pixels tall. Not visible. |
| **Subsurface Scattering Quality** | **Low** | Skin translucency — invisible at CRT pixel density. |

### Advanced Graphics — Textures & Detail

| Setting | Value | Notes |
|---------|-------|-------|
| **Texture Quality** | **Medium** | Textures are sampled at render resolution. Medium looks identical to Ultra at 480i output and avoids VRAM pressure on shared 16 GB. |
| **Anisotropy** | **4** | Texture sharpness at angles. 4x is the sweet spot; 16x produces no visible improvement at 480i. Nearly free on RDNA 2, but no reason to push it. |
| **Level of Detail (LOD)** | **Medium** | Controls when distant models simplify. Medium prevents obvious pop-in. High if FPS allows. |
| **Max Dynamic Decals** | **Low** | Bullet holes, environmental damage marks — too fine for 480i. |

### Advanced Graphics — Atmosphere

| Setting | Value | Notes |
|---------|-------|-------|
| **Volumetric Fog Resolution** | **Low** | Fog is soft by definition. Low vs Ultra is indistinguishable through 480i. Saves ~12% FPS. |
| **Volumetric Cloud Quality** | **Low** | Same reasoning — clouds are inherently low-frequency. Low looks great on CRT. |

### Ray Tracing (All Off)

| Setting | Value | Notes |
|---------|-------|-------|
| **Ray Tracing** | **Off** | Master toggle. Keep off for all sub-settings. |
| **Ray-Traced Reflections** | **Off** | Not viable on BC-250 at playable framerates. |
| **Ray-Traced Sun Shadows** | **Off** | Same. |
| **Ray-Traced Local Shadows** | **Off** | Same. |
| **Ray-Traced Lighting** | **Off** | Same. |
| **Path Tracing** | **Off** | Requires RTX 4070 Ti+ class hardware. |
| **Path Tracing in Photo Mode** | **Off** | Only useful for screenshots; can enable temporarily if desired. |

### Expected Performance

| Resolution | FSR | Estimated FPS | Notes |
|-----------|-----|--------------|-------|
| 720p | Off | 80–110 | Smooth, plenty of headroom |
| 720p | Quality | 100–130+ | Overkill for 60 Hz CRT but provides thermal/power headroom |
| 1080p | Off | 50–70 | May dip in dense areas |
| 1080p | Quality | 70–90 | Good balance if you want supersampled output |

These estimates are based on the BC-250's RX 6600-class GPU performance at Medium preset with RT Off. Actual results depend on driver version (Mesa 25.1+), GPU governor configuration, and scene complexity. Night City's densest areas (Jig-Jig Street, Kabuki Market) are the heaviest.

---

## Applying to Other Games — Quick Reference

The universal settings above translate to most modern titles. Here's how to map them:

### Open World Games (GTA V, Elden Ring, Witcher 3, etc.)

- Same shadow/reflection/fog philosophy as Cyberpunk
- **Grass/foliage density**: Medium — individual blades are invisible at 480i but sparse grass looks wrong
- **Water quality**: Low–Medium — water reflections can't resolve at 480i
- **Terrain quality**: Medium — ground detail beyond what 480 lines can show is wasted

### Competitive/Fast-Paced Games (shooters, racing)

- Prioritize **60 FPS locked** over visual quality
- Turn **everything** to Low except textures (Medium) and LOD (Medium)
- Motion clarity on CRT is already excellent due to phosphor response time (~0.01ms)

### Story/Cinematic Games (RPGs, walking sims)

- Can afford to push **textures to High** and **LOD to High**
- Keep **AO at Medium** for scene depth
- **Volumetric fog at Low** still provides atmosphere
- **DoF can be Low** instead of Off if the game uses it for story cinematics

### Source/Unity/Unreal Engine Common Settings

| Engine Setting | CRT Recommendation |
|---------------|-------------------|
| Anti-Aliasing (TAA/FXAA/MSAA) | Off |
| Bloom | Low or Off (CRT has natural bloom) |
| SSR / Reflections | Off or Low |
| SSAO / HBAO+ | Low–Medium |
| Shadow Maps | Low–Medium |
| Texture Streaming | Medium |
| Post-Process Quality | Low |
| Volumetric Lighting | Low |
| Tessellation | Off |
| Shader Quality | Medium |

---

## CRT-Specific Notes

### Philips 20PT6341/37 (Slot Mask, Component Input)

- Component video (YPbPr) provides the sharpest image this TV can produce
- 20" slot mask has moderate dot pitch — fine detail is softened more than aperture grille
- Supports 50 Hz PAL sync — useful for European titles
- The slot mask phosphor pattern adds visible texture that further masks aliasing
- **AKB circuit** may need disabling in service menu if image has streaking (see CRT Database notes)

### Sony KV-9PT40 (Aperture Grille, Composite Only)

- Composite video is the only input — significant color bleed and reduced chroma bandwidth
- 9" screen means individual pixels are physically tiny — fine detail is more visible than on the Philips despite lower input quality
- Aperture grille (Trinitron) provides sharper vertical lines than the Philips slot mask
- **No service menu** — all adjustments are via internal/external potentiometers
- LA7672 jungle chip — **cannot be RGB modded**
- Best suited for retro/CRT Mode rather than HD gaming due to composite-only limitation

### Converter Considerations

If using an HDMI-to-component converter to feed the Philips:
- Ensure the converter outputs 480i, not 480p (some converters force 480p which the TV may not handle well)
- Some converters introduce 1–2 frames of lag — unavoidable at this price point
- The converter's DAC quality affects color accuracy more than any in-game color setting

---

## Summary: The CRT Philosophy

The core principle: **CRT physics already provide what post-processing simulates.**

| Post-Processing Effect | CRT Equivalent | GPU Setting |
|-----------------------|----------------|-------------|
| Anti-aliasing | Phosphor bloom + beam profile | **Off** |
| Motion blur | Phosphor persistence (~1–3ms) | **Off** |
| Film grain | Phosphor dot structure + analog noise | **Off** |
| Chromatic aberration | Convergence fringing | **Off** |
| Vignette | Beam deflection edge darkening | **Off** |
| Sharpening | Already at analog bandwidth limit | **Off** |
| Bloom | Phosphor light bleed | **Off or Low** |

Spend your GPU budget on things that affect **scene composition** (shadows existing, AO depth, texture legibility, draw distance, fog presence) rather than things that affect **pixel-level fidelity** (shadow resolution, reflection detail, subsurface quality, contact shadows).

At 480i on a 15 kHz consumer CRT, you have roughly 320x240 effective pixels per field. Every GPU cycle spent on per-pixel refinement beyond what those ~77,000 pixels can resolve is wasted. Invest in framerate, scene completeness, and thermal headroom instead.
