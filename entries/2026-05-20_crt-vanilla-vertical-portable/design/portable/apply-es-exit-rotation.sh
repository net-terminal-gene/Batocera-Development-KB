#!/bin/bash
# Deploy portable ES exit rotation fix after CRT installer on Batocera v42/43.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH="${HOME}/bin/ssh-batocera.sh"

if [[ ! -x "$SSH" ]]; then
  echo "Missing ~/bin/ssh-batocera.sh" >&2
  exit 1
fi

b64() { base64 < "$1" | tr -d '\n'; }

echo "==> Backup scripts"
"$SSH" 'for f in /userdata/system/scripts/first_script.sh /userdata/system/scripts/first_script_right.sh; do
  [ -f "$f" ] && [ ! -f "${f}.bak-portable" ] && cp -a "$f" "${f}.bak-portable"
done; true'

echo "==> Deploy first_script.sh + first_script_right.sh"
"$SSH" "echo $(b64 "${SCRIPT_DIR}/first_script.sh") | base64 -d > /userdata/system/scripts/first_script.sh && chmod 755 /userdata/system/scripts/first_script.sh"
"$SSH" "echo $(b64 "${SCRIPT_DIR}/first_script_right.sh") | base64 -d > /userdata/system/scripts/first_script_right.sh && chmod 755 /userdata/system/scripts/first_script_right.sh"

echo "==> Patch rotation_fix.sh"
"$SSH" "echo $(b64 "${SCRIPT_DIR}/patch_rotation_fix.py") | base64 -d > /tmp/patch_rotation_fix.py && python3 /tmp/patch_rotation_fix.py"

echo "==> Remove duplicate restore scripts"
"$SSH" 'rm -f /userdata/system/scripts/~restore_es_rotation.sh /userdata/system/scripts/~restore_rotation.sh /userdata/system/scripts/zzz_restore_es_rotation.sh 2>/dev/null; true'

echo "==> Verify display.rotate"
"$SSH" 'grep -E "^display\.rotate=" /userdata/system/batocera.conf || echo "WARN: set display.rotate in batocera.conf or CRT installer"'

echo "Done. Test: launch MAME, quit, ES should return vertical (~6s)."
