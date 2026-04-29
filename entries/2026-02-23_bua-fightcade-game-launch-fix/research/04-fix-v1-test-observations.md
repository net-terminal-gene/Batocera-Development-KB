# Fix v1 Test — Post-Deployment Observations

Test of the fix deployed from the previous session. Three files were SCP'd to Batocera:
- `Resources/wine.sh`
- `extra/fcade-quark`
- Port launcher `Fightcade.sh`

---

## Step 1: App Launched + Logged In

Launched from Ports menu. User logged in successfully.

**Processes running:**
- `emulatorlauncher` (PID 18680) — port launcher
- `fc2-electron` (PID 19441) — main Fightcade UI + child processes (zygote, GPU, network, renderer)
- `tee -a fightcade.log` (PID 18844) — log capture

**No** `sym_wine.sh`, `fcade`, `wine`, or `fbneo` processes.

**Log (full sequence from this launch at 20:57):**
```
Mon Feb 23 08:57:09 PM MST 2026: Launching Fightcade
Registered fcade:// URL handler.
Initializing Wine prefix at /userdata/system/add-ons/fightcade/.wine...
Creating symlink: /usr/bin/wine -> /userdata/system/add-ons/fightcade/usr/bin/wine
Symlink created. Monitoring fc2-electron process...
fc2-electron is not running. Exiting script.
Script exiting. Symlink will be removed.
Removing symlink: /usr/bin/wine
Wine prefix initialized.
Fightcade exited.
```

### Issues Found

#### Issue 1: `sym_wine.sh` timing bug — symlink removed prematurely

The port launcher does these steps in order:
1. Register URL handler
2. Start `sym_wine.sh &` (background)
3. Run `wineboot -u` (BLOCKING — takes significant time)
4. Run `Fightcade2.sh`

Timeline:
- `sym_wine.sh` creates symlink immediately, waits 10s, checks for `fc2-electron`
- `wineboot -u` is still running → `Fightcade2.sh` hasn't launched → `fc2-electron` doesn't exist
- `sym_wine.sh` sees "fc2-electron is not running", removes symlink, exits
- `wineboot` finishes → `Fightcade2.sh` launches fc2-electron → but symlink is already gone

**Result:** `/usr/bin/wine` symlink does not exist. Confirmed:
```
ls -la /usr/bin/wine → (not found, exit 2)
```

#### Issue 2: `wine.sh` not present on filesystem

Despite being transferred via SCP in the previous session, the file is missing:
```
find /userdata/system/add-ons/fightcade/Fightcade/Resources/ -name 'wine*' → (no results)
```

[Inference] Possible causes: file was deployed to wrong path, or a subsequent reinstall/rewrite overwrote it.

#### Issue 3: `xdg-open` does not exist on Batocera

```
which xdg-open → (not found, exit 1)
```

The `.desktop` file and `mimeapps.list` were successfully written to `$HOME/.local/share/applications/`:
```
fcade-quark.desktop  — correct Exec= pointing to /userdata/system/add-ons/fightcade/extra/fcade-quark
mimeapps.list        — x-scheme-handler/fcade=fcade-quark.desktop
```

However, **without `xdg-open`**, `fc2-electron` has no standard mechanism to resolve `fcade://` URLs using these files. The `.desktop` + `mimeapps.list` approach relies on the `xdg-open` tool chain.

#### Issue 4: `fcade-quark` never invoked

```
cat /userdata/system/logs/fcade-quark.log → (file does not exist)
```

This confirms the URL dispatch chain is still broken — clicking "Test Game" would still result in a silent failure.

### Deployed File States

| File | Exists | Executable | Size |
|------|--------|------------|------|
| `extra/fcade-quark` | Yes | Yes | 476B |
| `Resources/wine.sh` | **No** | — | — |
| `.local/share/applications/fcade-quark.desktop` | Yes | — | 193B |
| `.local/share/applications/mimeapps.list` | Yes | — | 66B |
| `.wine/` (prefix) | Yes | — | Initialized |
| `/usr/bin/wine` (symlink) | **No** | — | Removed |

### Summary

The fix v1 has three blocking problems:

1. **Timing bug** — `wineboot -u` must run AFTER or in parallel with `Fightcade2.sh`, not before, so `sym_wine.sh` can see `fc2-electron`
2. **Missing `xdg-open`** — `.desktop` URL handler registration is inert without `xdg-open`. Need an alternative dispatch mechanism
3. **Missing `wine.sh`** — File not present at expected path
