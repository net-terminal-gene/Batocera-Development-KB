# 05 — Steam Launched Successfully on 2nd Try

## Date: 2026-05-07

## Context

After the `lbfix.sh`-induced crash on first launch, Steam launched successfully on the second attempt. The libcurl fix is already in place and `lbfix.sh` self-deleted, so no interference this time.

## State

- Steam Big Picture running (PID 16964 = steam.sh, inside bwrap container)
- `create-steam-launchers.sh` running (PID 16745, scanning every 5s)
- `lbfix.sh` no longer present (self-deleted after first run)
- `steamapps/common/` still does NOT exist (no Proton/SLR installed yet)
- User still needs to: log in, install Proton Experimental, add non-Steam games

## Confirmed: `lbfix.sh` is a First-Launch-Only Issue

The crash on first launch is a known behavior of the upstream BUA Steam addon. It only happens once because:
1. `lbfix.sh` replaces the libcurl symlink with a real file
2. `lbfix.sh` self-deletes (`rm -- "$0"`)
3. Second launch has no `lbfix.sh` to run (Launcher skips it: `if [[ -f "$LIB_FIX" ]]`)

## Next Step

User will log in to Steam, install Proton Experimental from Library, then add non-Steam game shortcuts.
