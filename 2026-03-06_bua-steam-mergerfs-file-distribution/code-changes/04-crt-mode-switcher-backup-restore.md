# Change 04: CRT — 03_backup_restore.sh (Mode Switcher Module)

## Status: DEPLOYED TO REMOTE BATOCERA

## File

**Local repo path:** `Batocera-CRT-Script/userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/03_backup_restore.sh`
**Remote path:** `/userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/03_backup_restore.sh`

## Why This File Is Critical

This module runs **every time the user switches between HD and CRT mode** via the Mode Switcher. After a mode switch, the system reboots, mergerfs mounts with `mfs` policy, and this module:
- Wipes and recreates `/userdata/roms/crt/` contents
- Copies mode-specific tools (HD: only mode_switcher; CRT: all tools)
- Restores or regenerates GunCon2 calibration
- Sets permissions on all CRT tool scripts
- Copies overlay/override scripts

Without this fix, **every single mode switch** would scatter CRT files to the external drive.

## What Was Changed

All 41 references to `/userdata/roms/crt` were replaced with `$CRT_ROMS/crt`. The `$CRT_ROMS` variable is inherited from the parent `mode_switcher.sh` (Change 03).

## Changes by Function/Section

### `get_video_output_xrandr()` — lines 181-182

Read operation, updated for consistency:

```diff
-    if [ -f "/userdata/roms/crt/GunCon2_Calibration.sh" ]; then
-        video_output=$(grep '--output' /userdata/roms/crt/GunCon2_Calibration.sh 2>/dev/null | ...)
+    if [ -f "$CRT_ROMS/crt/GunCon2_Calibration.sh" ]; then
+        video_output=$(grep '--output' "$CRT_ROMS/crt/GunCon2_Calibration.sh" 2>/dev/null | ...)
```

### `backup_mode_files()` — lines 497-498

Backup read+copy, updated for consistency:

```diff
-        if [ -f "/userdata/roms/crt/GunCon2_Calibration.sh" ]; then
-            cp -a "/userdata/roms/crt/GunCon2_Calibration.sh" "${backup_dir}/..." 2>/dev/null || true
+        if [ -f "$CRT_ROMS/crt/GunCon2_Calibration.sh" ]; then
+            cp -a "$CRT_ROMS/crt/GunCon2_Calibration.sh" "${backup_dir}/..." 2>/dev/null || true
```

### REINSTALL CRT TOOLS section — Step 1: Create directory

```diff
-    mkdir -p /userdata/roms/crt 2>/dev/null || true
+    mkdir -p "$CRT_ROMS/crt" 2>/dev/null || true
```

### Step 2a: HD Mode — Mode Selector only

```diff
-        rm -rf /userdata/roms/crt/* 2>/dev/null || true
-        mkdir -p /userdata/roms/crt/images 2>/dev/null || true
+        rm -rf "$CRT_ROMS/crt/"* 2>/dev/null || true
+        mkdir -p "$CRT_ROMS/crt/images" 2>/dev/null || true

-            cp .../mode_switcher.sh /userdata/roms/crt/mode_switcher.sh
-            chmod 755 /userdata/roms/crt/mode_switcher.sh
+            cp .../mode_switcher.sh "$CRT_ROMS/crt/mode_switcher.sh"
+            chmod 755 "$CRT_ROMS/crt/mode_switcher.sh"

-            cp .../mode_switcher.sh.keys /userdata/roms/crt/mode_switcher.sh.keys
-            chmod 644 /userdata/roms/crt/mode_switcher.sh.keys
+            cp .../mode_switcher.sh.keys "$CRT_ROMS/crt/mode_switcher.sh.keys"
+            chmod 644 "$CRT_ROMS/crt/mode_switcher.sh.keys"

-            mkdir -p /userdata/roms/crt/images
-                cp .../hd_crt_switcher-image.png /userdata/roms/crt/images/
-                cp .../hd_crt_switcher-logo.png /userdata/roms/crt/images/
-                cp .../hd_crt_switcher-thumb.png /userdata/roms/crt/images/
+            mkdir -p "$CRT_ROMS/crt/images"
+                cp .../hd_crt_switcher-image.png "$CRT_ROMS/crt/images/"
+                cp .../hd_crt_switcher-logo.png "$CRT_ROMS/crt/images/"
+                cp .../hd_crt_switcher-thumb.png "$CRT_ROMS/crt/images/"

-            cp .../gamelist.xml /userdata/roms/crt/gamelist.xml
-            chmod 644 /userdata/roms/crt/gamelist.xml
+            cp .../gamelist.xml "$CRT_ROMS/crt/gamelist.xml"
+            chmod 644 "$CRT_ROMS/crt/gamelist.xml"

-            cp .../CRT.svg /userdata/roms/crt/CRT.svg
-            chmod 644 /userdata/roms/crt/CRT.svg
-            cp .../CRT.png /userdata/roms/crt/CRT.png
-            chmod 644 /userdata/roms/crt/CRT.png
+            cp .../CRT.svg "$CRT_ROMS/crt/CRT.svg"
+            chmod 644 "$CRT_ROMS/crt/CRT.svg"
+            cp .../CRT.png "$CRT_ROMS/crt/CRT.png"
+            chmod 644 "$CRT_ROMS/crt/CRT.png"
```

### Step 2b: CRT Mode — All CRT Tools

```diff
-        rm -rf /userdata/roms/crt/* 2>/dev/null || true
-        mkdir -p /userdata/roms/crt 2>/dev/null || true
+        rm -rf "$CRT_ROMS/crt/"* 2>/dev/null || true
+        mkdir -p "$CRT_ROMS/crt" 2>/dev/null || true

-            cp -a .../crt/ /userdata/roms/ 2>/dev/null || true
+            cp -a .../crt/ "$CRT_ROMS/" 2>/dev/null || true

-            cp -a ".../GunCon2_Calibration.sh" "/userdata/roms/crt/GunCon2_Calibration.sh"
-            chmod 755 "/userdata/roms/crt/GunCon2_Calibration.sh"
+            cp -a ".../GunCon2_Calibration.sh" "$CRT_ROMS/crt/GunCon2_Calibration.sh"
+            chmod 755 "$CRT_ROMS/crt/GunCon2_Calibration.sh"

-                sed ... > /userdata/roms/crt/GunCon2_Calibration.sh
-                chmod 755 /userdata/roms/crt/GunCon2_Calibration.sh
+                sed ... > "$CRT_ROMS/crt/GunCon2_Calibration.sh"
+                chmod 755 "$CRT_ROMS/crt/GunCon2_Calibration.sh"
```

### Step 5: Set permissions (CRT Mode only)

```diff
-        chmod 755 /userdata/roms/crt/es_adjust_tool.sh
-        chmod 755 /userdata/roms/crt/geometry.sh
-        chmod 0644 /userdata/roms/crt/es_adjust_tool.sh.keys
-        chmod 0644 /userdata/roms/crt/geometry.sh.keys
-        chmod 755 /userdata/roms/crt/grid_tool.sh
-        chmod 0644 /userdata/roms/crt/grid_tool.sh.keys
+        chmod 755 "$CRT_ROMS/crt/es_adjust_tool.sh"
+        chmod 755 "$CRT_ROMS/crt/geometry.sh"
+        chmod 0644 "$CRT_ROMS/crt/es_adjust_tool.sh.keys"
+        chmod 0644 "$CRT_ROMS/crt/geometry.sh.keys"
+        chmod 755 "$CRT_ROMS/crt/grid_tool.sh"
+        chmod 0644 "$CRT_ROMS/crt/grid_tool.sh.keys"
```

### Step 9: Copy overlays_overrides.sh (CRT Mode only)

```diff
-            cp .../overlays_overrides.sh /userdata/roms/crt/
-            chmod 755 /userdata/roms/crt/overlays_overrides.sh
-            cp .../overlays_overrides.sh.keys /userdata/roms/crt/
-            chmod 644 /userdata/roms/crt/overlays_overrides.sh.keys
+            cp .../overlays_overrides.sh "$CRT_ROMS/crt/"
+            chmod 755 "$CRT_ROMS/crt/overlays_overrides.sh"
+            cp .../overlays_overrides.sh.keys "$CRT_ROMS/crt/"
+            chmod 644 "$CRT_ROMS/crt/overlays_overrides.sh.keys"
```

### Verification block

```diff
-    if [ ! -d "/userdata/roms/crt" ]; then
-        echo "...: ERROR: /userdata/roms/crt does NOT exist!" >> "$LOG_FILE"
+    if [ ! -d "$CRT_ROMS/crt" ]; then
+        echo "...: ERROR: $CRT_ROMS/crt does NOT exist!" >> "$LOG_FILE"
     else
-        echo "...: VERIFIED: /userdata/roms/crt exists" >> "$LOG_FILE"
-        ls -la /userdata/roms/crt/*.sh 2>/dev/null | head -5 >> "$LOG_FILE" || true
+        echo "...: VERIFIED: $CRT_ROMS/crt exists" >> "$LOG_FILE"
+        ls -la "$CRT_ROMS/crt/"*.sh 2>/dev/null | head -5 >> "$LOG_FILE" || true
     fi
```

## Summary

| Metric | Count |
|--------|-------|
| Total `/userdata/roms/crt` references replaced | 41 |
| Remaining `/userdata/roms/crt` references | 0 |
| Variable source | Inherited from `mode_switcher.sh` parent (`$CRT_ROMS`) |
