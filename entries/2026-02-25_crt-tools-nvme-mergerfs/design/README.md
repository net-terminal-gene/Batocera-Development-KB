# Design — CRT Tools on Boot Drive (mergerFS Conflict)

## Architecture

### Conflict Diagram

```
mergerFS pool: /userdata/roms
├── .roms_base (boot drive) =NC  ← no new file creation
├── BATO-ALL/roms
├── BATO-PARROT/roms
└── BATO-LG/roms

/userdata/roms/crt/  →  currently on BATO-PARROT (wrong)
                        with =NC: new writes go to external drives
                        required: must be on boot drive (NVMe/SATA/microSD)
```

### Why CRT Tools Must Be on the Boot Drive

1. **Mode switch timing** — User selects HD or CRT and reboots. Storage manager may not have mounted external drives yet when mode switcher runs.
2. **Single-drive boot** — User may boot with only the boot drive (no externals connected). CRT tools must be available.
3. **Read dependency** — `get_video_output_xrandr()` reads `GunCon2_Calibration.sh` from `/userdata/roms/crt/` to determine video output.
4. **Write dependency** — `restore_mode_files()` reinstalls CRT tools to `/userdata/roms/crt/` on every mode switch (HD and CRT).

### Bind Mount Flow (Option A)

```
Boot
  ↓
S11share / batocera-storage-manager → mergerFS mounts /userdata/roms
  ↓
[custom script or init.d]
  mkdir -p /userdata/.roms_base/crt
  mount --bind /userdata/.roms_base/crt /userdata/roms/crt
  ↓
/userdata/roms/crt now points to boot drive (overlays mergerFS view)
  ↓
Mode switcher / EmulationStation read-write /userdata/roms/crt
  → all I/O goes to boot drive
```

### Migration Steps (One-Time)

1. Copy existing CRT content from BATO-PARROT to boot drive:
   ```bash
   mkdir -p /userdata/.roms_base/crt
   cp -a /media/BATO-PARROT/roms/crt/* /userdata/.roms_base/crt/
   ```
2. (Optional) Remove from BATO-PARROT to avoid confusion.
3. Add bind mount to boot sequence.
4. Reboot and verify.
