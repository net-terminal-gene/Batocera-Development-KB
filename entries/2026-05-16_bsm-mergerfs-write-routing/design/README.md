# Design — mergerFS Write Routing and S12populateshare Awareness

## Architecture

### Current boot sequence (problematic)

```
S12populateshare        →  populates /userdata/roms/{system} from datainit
                              (mergerFS not mounted yet, no external drive awareness)
batocera-storage-manager →  mv /userdata/roms/* → .roms_base/
                              (silent mv failure if .roms_base/{system} non-empty)
mergerfs mount           →  .roms_base + external branches → /userdata/roms
                              (stock gamelist in .roms_base shadows external gamelist)
EmulationStation         →  reads gamelist via merged view
                              (gets wrong gamelist, artwork missing)
```

### Proposed boot sequence

```
S12populateshare        →  checks batocera-boot.conf for mergerfs.roms
                              if system exists on ANY configured branch, skip
                              otherwise populate as before
batocera-storage-manager →  mv /userdata/roms/* → .roms_base/
                              then: dedup gamelists (remove .roms_base copy if external has one)
mergerfs mount           →  .roms_base + external branches → /userdata/roms
                              optional: apply per-system func.create overrides
EmulationStation         →  reads correct gamelist from external drive
```

### mergerFS policy options

| Policy | Behavior | Batocera use |
|--------|----------|--------------|
| `eplfs` | Existing path, least free space | Current default for create |
| `epff` | Existing path, first found | Would respect branch order |
| `epmfs` | Existing path, most free space | Fills big drives first |
| `ff` | First found | Current default for read/open |
| `path` | Path-based (via runtime API) | Phase 3 per-system routing |

### mergerFS runtime control

mergerFS exposes a control file at the mount root: `/userdata/roms/.mergerfs`. Writing to it can change policies at runtime:

```bash
# Change create policy for a specific path
xattr -w user.mergerfs.srcmounts '/userdata/.roms_base:/media/BATO-ALL/roms' /userdata/roms/.mergerfs
```

Phase 3 would use `func.create.policy` with path-based overrides.
