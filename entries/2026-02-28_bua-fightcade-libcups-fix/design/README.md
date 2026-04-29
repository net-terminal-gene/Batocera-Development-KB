# Design — BUA Fightcade libcups Fix

## Architecture

```
Fightcade port launcher (Fightcade.sh)
  ├── export LD_LIBRARY_PATH="/userdata/system/add-ons/.dep:${LD_LIBRARY_PATH}"
  ├── export DISPLAY=:0.0
  ├── export HOME=/userdata/system/add-ons/fightcade
  └── ./Fightcade2.sh
        └── fc2-electron (Electron binary)
              └── dlopen("libcups.so.2") → resolves via LD_LIBRARY_PATH
```

The `.dep` directory is a shared dependency cache used by multiple BUA add-ons (Chrome, Greenlight, Amazon Luna). Fightcade now explicitly prepends it so fc2-electron finds libcups regardless of launch order or environment.
