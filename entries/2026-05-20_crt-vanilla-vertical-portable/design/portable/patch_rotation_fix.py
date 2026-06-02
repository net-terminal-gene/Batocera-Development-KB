#!/usr/bin/env python3
"""Patch rotation_fix.sh to skip gameStop when display.rotate is set (idempotent)."""
from __future__ import annotations

import sys

PATH = "/usr/share/batocera/configgen/scripts/rotation_fix.sh"
MARKER = "Vertical CRT: userdata first_script_right.sh already calls setRotation once"

OLD = """    gameStop)
        if [[ "$3" == "mame" ]]; then
            if [[ "$(batocera-resolution getDisplayMode)" == "xorg" ]]; then
                rotation=$(batocera-resolution getRotation)
                [[ -n "$rotation" ]] && batocera-resolution setRotation "$rotation"
            fi
        fi"""

NEW = """    gameStop)
        # Vertical CRT: userdata first_script_right.sh already calls setRotation once
        TATE_ROT=$(batocera-settings-get display.rotate 2>/dev/null)
        if [[ -n "$TATE_ROT" && "$TATE_ROT" != "0" ]]; then
            exit 0
        fi
        if [[ "$3" == "mame" ]]; then
            if [[ "$(batocera-resolution getDisplayMode)" == "xorg" ]]; then
                rotation=$(batocera-resolution getRotation)
                [[ -n "$rotation" ]] && batocera-resolution setRotation "$rotation"
            fi
        fi"""


def main() -> int:
    with open(PATH, encoding="utf-8") as f:
        data = f.read()
    if MARKER in data:
        print("rotation_fix.sh already patched")
        return 0
    if OLD not in data:
        print("rotation_fix.sh: patch target not found", file=sys.stderr)
        return 1
    bak = PATH + ".bak.tate"
    if not __import__("os").path.isfile(bak):
        with open(bak, "w", encoding="utf-8") as f:
            f.write(data)
    with open(PATH, "w", encoding="utf-8") as f:
        f.write(data.replace(OLD, NEW, 1))
    print("patched rotation_fix.sh")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
