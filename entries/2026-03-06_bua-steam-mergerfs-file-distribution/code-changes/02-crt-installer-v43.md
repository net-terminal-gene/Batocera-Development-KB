# Change 02: CRT — Batocera-CRT-Script-v43.sh (Installer)

## Status: LOCAL REPO ONLY — NOT DEPLOYED TO REMOTE

## File

**Local repo path:** `Batocera-CRT-Script/userdata/system/Batocera-CRT-Script/Batocera_ALLINONE/Batocera-CRT-Script-v43.sh`

This is the main CRT Script installer. It runs once during initial setup to install CRT tools, geometry adjusters, mode switcher, overlays, and GunCon2 calibration.

## What Was Changed

Added a `CRT_ROMS` variable near line 5069 and updated all `/userdata/roms/crt` write targets to use `$CRT_ROMS/crt`.

## Diff

```diff
 #######################################################################################
 # Create files for adjusting your CRT
 #######################################################################################
-cp -a /userdata/system/Batocera-CRT-Script/Geometry_modeline/crt/ /userdata/roms/
+# Pin CRT tools to internal drive to avoid mergerfs scattering to external drives
+if [ -d "/userdata/.roms_base" ]; then
+  CRT_ROMS="/userdata/.roms_base"
+else
+  CRT_ROMS="/userdata/roms"
+fi
+cp -a /userdata/system/Batocera-CRT-Script/Geometry_modeline/crt/ "$CRT_ROMS/"
```

All subsequent write targets in the installer were updated:

```diff
-chmod 755 /userdata/roms/crt/es_adjust_tool.sh
-chmod 755 /userdata/roms/crt/geometry.sh
+chmod 755 "$CRT_ROMS/crt/es_adjust_tool.sh"
+chmod 755 "$CRT_ROMS/crt/geometry.sh"

-chmod 0644 /userdata/roms/crt/es_adjust_tool.sh.keys
-chmod 0644 /userdata/roms/crt/geometry.sh.keys
-chmod 755 /userdata/roms/crt/grid_tool.sh
+chmod 0644 "$CRT_ROMS/crt/es_adjust_tool.sh.keys"
+chmod 0644 "$CRT_ROMS/crt/geometry.sh.keys"
+chmod 755 "$CRT_ROMS/crt/grid_tool.sh"

-chmod 0644 /userdata/roms/crt/grid_tool.sh.keys
+chmod 0644 "$CRT_ROMS/crt/grid_tool.sh.keys"
```

Mode switcher copy section:

```diff
-    cp .../mode_switcher.sh /userdata/roms/crt/mode_switcher.sh
-    chmod 755 /userdata/roms/crt/mode_switcher.sh
+    cp .../mode_switcher.sh "$CRT_ROMS/crt/mode_switcher.sh"
+    chmod 755 "$CRT_ROMS/crt/mode_switcher.sh"

-        cp .../mode_switcher.sh.keys /userdata/roms/crt/mode_switcher.sh.keys
-        chmod 644 /userdata/roms/crt/mode_switcher.sh.keys
+        cp .../mode_switcher.sh.keys "$CRT_ROMS/crt/mode_switcher.sh.keys"
+        chmod 644 "$CRT_ROMS/crt/mode_switcher.sh.keys"

-        cp .../gamelist.xml /userdata/roms/crt/gamelist.xml
-        chmod 644 /userdata/roms/crt/gamelist.xml
+        cp .../gamelist.xml "$CRT_ROMS/crt/gamelist.xml"
+        chmod 644 "$CRT_ROMS/crt/gamelist.xml"
```

Overlays/overrides section:

```diff
-cp .../overlays_overrides.sh /userdata/roms/crt
-cp .../overlays_overrides.sh.keys /userdata/roms/crt
-chmod 755 /userdata/roms/crt/overlays_overrides.sh
-chmod 644 /userdata/roms/crt/overlays_overrides.sh.keys
+cp .../overlays_overrides.sh "$CRT_ROMS/crt"
+cp .../overlays_overrides.sh.keys "$CRT_ROMS/crt"
+chmod 755 "$CRT_ROMS/crt/overlays_overrides.sh"
+chmod 644 "$CRT_ROMS/crt/overlays_overrides.sh.keys"
```

GunCon2 calibration generation:

```diff
-sed -e "s/\[card_display\]/$video_modeline/g" .../GunCon2_Calibration.sh-generic > /userdata/roms/crt/GunCon2_Calibration.sh
-chmod 755 /userdata/roms/crt/GunCon2_Calibration.sh
+sed -e "s/\[card_display\]/$video_modeline/g" .../GunCon2_Calibration.sh-generic > "$CRT_ROMS/crt/GunCon2_Calibration.sh"
+chmod 755 "$CRT_ROMS/crt/GunCon2_Calibration.sh"
```

## What Was NOT Changed (Intentionally)

- **Line 359** — `DIRS_TO_REMOVE` array entry `"/userdata/roms/crt"`. This is the uninstall/restore path. Deletions must go through the merged view to find files on any branch.
- **Lines 5136-5137** — Commented-out dead code (`#cp`, `#chmod`). No effect.

## Write Operations Protected (14 total)

| Operation | Target |
|-----------|--------|
| `cp -a crt/` | `$CRT_ROMS/` |
| `chmod 755` | `es_adjust_tool.sh` |
| `chmod 755` | `geometry.sh` |
| `chmod 0644` | `es_adjust_tool.sh.keys` |
| `chmod 0644` | `geometry.sh.keys` |
| `chmod 755` | `grid_tool.sh` |
| `chmod 0644` | `grid_tool.sh.keys` |
| `cp` + `chmod 755` | `mode_switcher.sh` |
| `cp` + `chmod 644` | `mode_switcher.sh.keys` |
| `cp` + `chmod 644` | `gamelist.xml` |
| `cp` + `chmod 755` | `overlays_overrides.sh` |
| `cp` + `chmod 644` | `overlays_overrides.sh.keys` |
| `sed >` + `chmod 755` | `GunCon2_Calibration.sh` |
