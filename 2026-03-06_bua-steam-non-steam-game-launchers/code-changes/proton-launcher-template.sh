#!/bin/bash
# Non-Steam Game Launcher — Proton direct launch (bypasses Steam)
# Template: SHORTCUTID, GAMENAME, EXE_PATH, START_DIR, PROTON_NAME
export RIM_ALLOW_ROOT=1
export HOME=/userdata/system/add-ons/steam
ulimit -H -n 819200 && ulimit -S -n 819200
#------------------------------------------------
# Non-Steam Game Launcher (Proton direct)
# Game: GAMENAME
# ShortcutID: SHORTCUTID

STEAM_DIR="/userdata/system/add-ons/steam"
STEAM_APPS="${STEAM_DIR}/.local/share/Steam/steamapps"
COMPAT_DATA="${STEAM_APPS}/compatdata/SHORTCUTID"
STEAM_COMPAT_CLIENT_INSTALL_PATH="${STEAM_DIR}/.local/share/Steam"
PROTON_PATH="${STEAM_APPS}/common/PROTON_NAME/proton"
EXE_PATH="EXE_PATH"
START_DIR="START_DIR"

cd "$STEAM_DIR" || exit 1

# Proton direct launch — bypasses Steam
export STEAM_COMPAT_DATA_PATH="$COMPAT_DATA"
export STEAM_COMPAT_CLIENT_INSTALL_PATH
export STEAM_COMPAT_APP_ID=SHORTCUTID

"$PROTON_PATH" run "$EXE_PATH" &
PROTON_PID=$!

wait $PROTON_PID

# Cleanup
pkill -f steam 2>/dev/null || true
pkill -f steamwebhelper 2>/dev/null || true
#------------------------------------------------
