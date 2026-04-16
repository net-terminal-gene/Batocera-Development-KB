# Design — CRT Boot Resolution Persistence

## Architecture

The mode switcher backup/restore flow:
1. CRT Mode -> HD Mode: `backup_mode_files "crt"` saves current CRT config
2. HD Mode -> CRT Mode: `restore_mode_files "crt"` restores saved CRT config

Key files that should preserve boot resolution:
- `batocera.conf` (`global.videomode`, `es.resolution`, `CRT.videomode`)
- `videomodes.conf`
- syslinux boot config (APPEND line with resolution)

Need to trace whether the backup/restore cycle captures and restores all of these.
