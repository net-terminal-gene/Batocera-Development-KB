# Debug — Myzar DisplayPort Hybrid Switchres

## Verification (read-only)

```bash
# Symlinks
readlink /usr/bin/batocera-resolution
readlink /usr/bin/batocera-resolution-hdmi
head -12 /userdata/system/custom.sh

# Settings
grep -E "mame.switchres|display.rotate|videooutput|es.resolution" /userdata/system/batocera.conf

# Display (do not run switchres probes on live cabinet)
export DISPLAY=:0
xrandr --query | grep -E "DisplayPort-0|current"
tail -20 /userdata/system/logs/display.log

# From Mac
bash ~/.cursor/skills/myzar-dp/scripts/verify-myzar-dp.sh
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| All MAME at 640×480, no super-res modes in `xrandr` | Symlink → hdmi; `custom.sh` exit before myzar block |
| Menu landscape after game exit | gameStop rotation skipped (old `is_menu_mode`); or duplicate scripts |
| ~30s to exit game | Rotation-lock loop; multiple `setRotation`; stuck `gameStart` |
| Narrow column / pillarbox in game | Per-game cfg `rotate="270"`; `keepaspect=1`; CV1000 **ddpsdoj** needs [ddpsdoj doc](ddpsdoj-saidaioujou-known-good.md) |
| MAME upside down, FBNeo OK (or reverse) | `xrandr right` on MAME `320×240`; or `setMode` rm'd `myzar-cabinet-rotate` — see [04](04-mame-fbneo-rotation-coexistence-pass.md) |
| Saturn pillarbox / flipped | Wrong SR width, aspect 22, 640×480 viewport, or Sai `xrandr right` on Saturn — see [05](saturn-beetle-core-crt.md) |
| ES broken after remote session | Live switchres left wrong mode; X dead — reboot |
| `xrandr: cannot find mode 320x240` | hdmi path without Switchres wrapper |
| Video Mode dropdown only 640×480 | hdmi wrapper not routing `listModes` to CRT |

## Emergency menu restore

```bash
bash ~/.cursor/skills/myzar-dp/scripts/emergency-restore-display.sh
```

Does **not** set `mame.switchres=0`.

## Known-good per title

| Emulator | Game | ROM | Doc |
|----------|------|-----|-----|
| FBNeo | DoDonPachi SaiDaiOuJou | `ddpsdoj.zip` | [ddpsdoj-saidaioujou-known-good.md](ddpsdoj-saidaioujou-known-good.md) — **PASS** |
| MAME | ddpdoj / dfkbl class | various | [04-mame-fbneo-rotation-coexistence-pass.md](04-mame-fbneo-rotation-coexistence-pass.md) — **PASS** (with FBNeo) |
| Saturn | Beetle core (all titles) | `.chd` | [saturn-beetle-core-crt.md](saturn-beetle-core-crt.md) — **PASS** (core-wide; not per-game stretch) |

## Regression log

| # | Topic |
|---|--------|
| 04 | [MAME + FBNeo rotation coexistence](04-mame-fbneo-rotation-coexistence-pass.md) |
| 05 | [Saturn Beetle core CRT](saturn-beetle-core-crt.md) |

## CRT spot-check (user)

1. Reboot → menu 480×640 rotated
2. Launch **ddpdoj** → wide timing (~1536×224), rotate normal in-game
3. Launch **ddpsdoj** (Sai, FBNeo) → `1280×240` + `xrandr right`, full width — see linked doc
4. Exit → menu rotated within a few seconds
5. Launch **pacman** → 288×224 class timing
6. Reboot again → symlinks still myzar

## Multi-emulator matrix

Expected resolution per system: `../research/emulator-expected-resolutions.md`. Suggested order: SNES → PCE → FBNeo → DC/Naomi/Saturn/PSX → PS2/PSP → Windows buckets → NES/Vectrex.
