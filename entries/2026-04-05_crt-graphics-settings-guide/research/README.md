# Research — CRT Graphics Settings Guide

## Sources

### CRT Display Physics

- [CRT Database — Philips 20PT6341/37](https://crtdatabase.com/crts/philips/philips-20pt6341-37) — Slot mask, 15 kHz, component, 20"
- [CRT Database — Sony KV-9PT40](https://crtdatabase.com/crts/sony/sony-kv-9pt40) — Aperture grille (Trinitron), 15 kHz, composite only, 9"
- [Cathode Retro Docs — Faking CRT](https://www.cathoderetro.com/docs/how/faking-crt.html) — Phosphor diffusion, scanline gaps, interlacing mechanics
- [nyanpasu64 — CRT Appearance](https://nyanpasu64.gitlab.io/blog/crt-appearance-tv-monitor/) — Horizontal blur, phosphor texture, convergence
- [Quora — CRT anti-aliasing](https://www.quora.com/Since-CRT-TVs-dont-have-pixels-like-new-monitors-do-they-still-require-anti-aliasing) — Phosphor persistence, beam overscan, analog smear
- [nyanpasu64 — Playing Stray on CRT 480i](https://nyanpasu64.gitlab.io/blog/amdgpu-stray-crt-480i/) — Modern game at 480i via amdgpu, modeline configuration

### Hardware (BC-250)

- [BC-250.info](https://bc250.info/) — 6x Zen 2, 24 RDNA 2 CUs, 16 GB GDDR6, RX 6600-class
- [AMD BC250 Documentation — Specifications](https://elektricm.github.io/amd-bc250-docs/hardware/specifications/) — GPU freq, memory bandwidth
- [AMD BC250 Documentation — Performance Issues](https://elektricm.github.io/amd-bc250-docs/troubleshooting/performance/) — GPU governor requirement
- [AMD BC250 Documentation — RADV Driver](https://elektricm.github.io/amd-bc250-docs/drivers/radv/) — Mesa/Vulkan support

### Cyberpunk 2077 Settings

- [Game8 — All Available Settings](https://game8.co/games/Cyberpunk-2077/archives/Settings-Guide-All-Available-Settings) — Complete settings reference (Update 2.1+)
- [SmoothFPS — Best Settings for Every PC (2026)](https://smoothfps.com/games/cyberpunk-2077) — Per-setting performance impact data (SSR ~40%, fog ~12%, AO ~8%, color precision ~5-6%)
- [PCOptimizedSettings — Optimization Guide 2025](https://pcoptimizedsettings.com/cyberpunk-2077-optimized-settings-2024-graphics-benchmark/) — Preset benchmarks, per-tier recommendations
- [GamingOnLinux — Cyberpunk 2077 2.0 on Linux](https://www.gamingonlinux.com/2023/09/cyberpunk-2077-2-0-on-steam-deck-and-desktop-linux/) — Proton compatibility, Steam Deck settings

### CRT-Script Codebase (verified)

- `02_hd_output_selection.sh` — HD Mode clears videomode, uses xrandr auto-detect, prefers 1920x1080@60
- `03_backup_restore.sh` — HD restore clears `global.videomode` and `es.resolution` for auto mode
- `batocera-resolution-v43` (patched) — 4096x2160 exclusion, ≥59 Hz filter, `forceMode` via cvt, `defineMode` via switchres

## Methodology

1. Identified all CRT phosphor properties that replicate digital post-processing effects
2. Mapped each property to the GPU settings it makes redundant
3. Analyzed 480i resolving power (~240 lines per field, ~77K effective pixels) against each setting's visual impact
4. Cross-referenced BC-250 GPU capability against setting performance costs
5. Verified HD Mode behavior from CRT-Script source code
6. Compiled complete Cyberpunk 2077 setting list from Game8 reference and in-game menus

## Key Finding

The main guide is at `research/CRT-Graphics-Settings-Guide.md`.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

