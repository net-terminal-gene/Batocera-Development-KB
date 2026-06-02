# Captured bundle (run locally)

Agent capture failed (SSH expect PTY limit). **Run once from your Mac terminal** while Batocera is online:

```bash
bash Batocera-Development-KB/entries/2026-05-20_crt-vanilla-vertical-portable/design/scripts/capture-vertical-bundle.sh
```

Then copy MAME cfgs (large):

```bash
mkdir -p Batocera-Development-KB/entries/2026-05-20_crt-vanilla-vertical-portable/design/captured/vertical-bundle-YYYYMMDD/mame-cfg
rsync -av root@batocera.local:/userdata/system/configs/mame/*.cfg \
  Batocera-Development-KB/entries/2026-05-20_crt-vanilla-vertical-portable/design/captured/vertical-bundle-YYYYMMDD/mame-cfg/
```

Expected: `batocera.conf` with `display.rotate=1`, scripts, **1066** `.cfg` files, `BUILD_15KHz` log tail.

Until capture succeeds, use **`design/portable/`** scripts as canonical for event hooks.
