# PR Status — Fightcade Switchres CRT Integration

## PR [#156](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons/pull/156)

**Repo:** `batocera-unofficial-addons/batocera-unofficial-addons`  
**Branch:** `net-terminal-gene:fightcade-switchres-crt`  
**Base:** `main`  
**Status:** OPEN Draft  
**Created:** 2026-05-05

### Files

| File | Change |
|------|--------|
| `fightcade/switchres_fightcade_wrap.template.sh` | New (491 lines): CRT wrapper template |
| `fightcade/fightcade.sh` | +16/-2: render template at install, route xdg-open through wrapper |

### Testing on existing installs (no reinstall needed)

```bash
# 1. Deploy wrapper
mkdir -p /userdata/system/add-ons/fightcade/extra
sed 's|__FIGHTCADE_ADDON__|/userdata/system/add-ons/fightcade|g' \
  switchres_fightcade_wrap.template.sh \
  > /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh
chmod +x /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh

# 2. Patch xdg-open shim
sed -i 's|/Fightcade/emulator/fcade.sh|/extra/switchres_fightcade_wrap.sh|' \
  /userdata/roms/ports/Fightcade.sh
```
