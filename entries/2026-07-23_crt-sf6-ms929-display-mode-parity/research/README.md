# Research — CRT SF6 / ms929 Display Mode Parity

## Findings (summary)

1. **Single settings file:** SF6 on these Batocera boxes uses only game-dir `config.ini`. No Capcom AppData graphics store in the Proton prefix (BC-250 audited live).
2. **Resolution is an index:** `FullScreenDisplayMode` indexes `DisplayModeN_*` rewritten from OS modes.
3. **XRandR exposure ≠ Switchres catalog:** Both machines’ `batocera-resolution listModes` is huge; only **xrandr’s connected output mode list** feeds SF6. BC-250 exposes 3; 7700 exposes many.
4. **Same game binary** on both (`buildid` 23395122, matching exe MD5).
5. **GPU differs** (BC-250 GFX1013 vs Navi32) and is recorded in `Render/Adapter` — but quality keys on the good box are ordinary (TAA, DoF, Bloom, 100% IQ). Softness tracked with junk `DisplayMode0`, not missing Ultra presets.
6. **Steam stack differs** (Flatpak+Proton Experimental vs BUA). Flatpak alone did not fix 7700; mode list remains mandatory.

## Documents

| File | Contents |
|------|----------|
| [bc250-golden-reference.md](bc250-golden-reference.md) | Perfect-machine inventory |
| [rx7700-broken-state.md](rx7700-broken-state.md) | Bad-machine inventory + failed experiments |
| [bc250-sf6-full-audit.out](bc250-sf6-full-audit.out) | Raw SSH audit (~756KB) |
