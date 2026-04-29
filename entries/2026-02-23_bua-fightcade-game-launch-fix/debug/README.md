# Debug — BUA Fightcade Game Launch Fix

## Verification

```bash
# Check URL handler is registered
cat /userdata/system/add-ons/fightcade/.local/share/applications/fcade-quark.desktop
cat /userdata/system/add-ons/fightcade/.local/share/applications/mimeapps.list

# Check fcade-quark script exists and is executable
ls -la /userdata/system/add-ons/fightcade/extra/fcade-quark

# Check wine.sh wrapper exists at expected relative path
ls -la /userdata/system/add-ons/fightcade/Resources/wine.sh

# Check Wine prefix was initialized
ls -la /userdata/system/add-ons/fightcade/.wine/

# Check wine symlink (while Fightcade is running)
ls -la /usr/bin/wine

# Monitor URL handler invocations
tail -f /userdata/system/logs/fcade-quark.log

# Monitor ROM manager
tail -f /userdata/system/logs/frm.log

# Check processes during game launch
ps aux | grep -iE 'fcade|wine|fbneo|frm'
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Click Test Game, nothing happens | URL handler not registered — check .desktop + mimeapps.list |
| fcade-quark.log shows URLs but no game launches | fcade binary can't find wine.sh — check Resources/wine.sh exists |
| Wine crashes immediately | WINEPREFIX not initialized — delete .wine dir and relaunch |
| ROM not found error | frm not invoked or network issue — check frm.log |
| "Please install wine 32bit" dialog | wine symlink not created — check sym_wine.sh is running |

## Step-by-Step Observations

See research/ for detailed step-by-step logs from BUA (01) and Flatpak (02) sessions.
