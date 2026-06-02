#!/bin/bash
# One-shot capture from current Batocera before retiring the image.
# Usage: bash capture-vertical-bundle.sh [ssh-host-script]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESIGN_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
KB_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
SSH="${1:-${HOME}/bin/ssh-batocera.sh}"
STAMP="$(date +%Y%m%d)"
OUT="${DESIGN_DIR}/captured/vertical-bundle-${STAMP}"
ARCHIVE="${DESIGN_DIR}/captured/vertical-bundle-${STAMP}.tar.gz"

if [[ ! -x "$SSH" ]]; then
  echo "Missing SSH helper: $SSH" >&2
  exit 1
fi

mkdir -p "$OUT"

echo "==> Capturing configs and scripts"
"$SSH" "cat /userdata/system/batocera.conf" > "${OUT}/batocera.conf"
"$SSH" "cat /userdata/system/scripts/first_script.sh" > "${OUT}/first_script.sh" 2>/dev/null || true
"$SSH" "cat /userdata/system/scripts/first_script_right.sh" > "${OUT}/first_script_right.sh" 2>/dev/null || true
"$SSH" "cat /boot/batocera-boot.conf" > "${OUT}/batocera-boot.conf" 2>/dev/null || true
"$SSH" "cat /etc/switchres.ini" > "${OUT}/switchres.ini" 2>/dev/null || true
"$SSH" "cat /userdata/system/configs/mame/mame.ini" > "${OUT}/mame.ini" 2>/dev/null || true
"$SSH" "cat /userdata/system/configs/mame/ui.ini" > "${OUT}/ui.ini" 2>/dev/null || true
"$SSH" "cat /usr/share/batocera/configgen/scripts/rotation_fix.sh" > "${OUT}/rotation_fix.sh" 2>/dev/null || true
"$SSH" "batocera-version" > "${OUT}/batocera-version.txt" 2>/dev/null || true
"$SSH" "grep -E '^(display|mame|global|psx|psp|ps2|fbneo|es\\.)' /userdata/system/batocera.conf" > "${OUT}/batocera-rotation-keys.txt" 2>/dev/null || true
"$SSH" "ls /userdata/system/configs/mame/*.cfg 2>/dev/null | wc -l" > "${OUT}/mame-cfg-count.txt" 2>/dev/null || true
"$SSH" "cat /userdata/system/logs/BUILD_15KHz_Batocera.log 2>/dev/null | tail -200" > "${OUT}/BUILD_15KHz_tail.log" 2>/dev/null || true

echo "==> Capturing MAME per-game cfgs (may take a few minutes)"
mkdir -p "${OUT}/mame-cfg"
if command -v rsync >/dev/null && [[ -f "${HOME}/bin/rsync-batocera.sh" || -x "${HOME}/bin/ssh-batocera.sh" ]]; then
  RSYNC_SH="${HOME}/bin/rsync-batocera.sh"
  if [[ -x "$RSYNC_SH" ]]; then
    "$RSYNC_SH" "root@batocera.local:/userdata/system/configs/mame/*.cfg" "${OUT}/mame-cfg/" || \
      echo "WARN: rsync mame cfgs failed; run manual rsync" >&2
  else
    echo "WARN: rsync-batocera.sh not found; copy mame cfgs manually:" >&2
    echo "  rsync -av root@batocera.local:/userdata/system/configs/mame/*.cfg ${OUT}/mame-cfg/" >&2
  fi
else
  echo "WARN: rsync not available; MAME cfgs not copied" >&2
fi

cat > "${OUT}/README.txt" <<EOF
Captured $(date -Iseconds) for KB session crt-vanilla-vertical-portable.
Target: official Batocera v42/v43 + CRT script. No DisplayPort hack.
Restore order: see design/file-manifest.md
EOF

tar -czf "$ARCHIVE" -C "${DESIGN_DIR}/captured" "$(basename "$OUT")"
echo "Done: $ARCHIVE"
echo "Also extracted tree: $OUT"
