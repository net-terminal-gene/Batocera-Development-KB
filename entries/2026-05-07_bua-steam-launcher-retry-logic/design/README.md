# Design — BUA Steam: Launcher Retry Logic

## Architecture

### Current Flow (broken)

```
Launcher starts
  ├── create-steam-launchers.sh &   (background)
  ├── lbfix.sh &                    (background, races with Steam)
  └── steam -gamepadui &            (background)
       │
       ├── Steam creates pinned_libs_64/libcurl.so.4 (symlink)
       │
       ├── lbfix.sh detects symlink, rm + curl replaces it
       │   └── Steam CRASHES (libcurl yanked)
       │
       └── Launcher detects window gone
            └── pkill -f steam → exit to ES
```

### Proposed Flow (retry-aware)

TBD based on chosen approach (see plan.md for options A/B/C)
