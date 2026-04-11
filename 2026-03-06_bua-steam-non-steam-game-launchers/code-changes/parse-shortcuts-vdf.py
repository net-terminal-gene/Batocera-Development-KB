#!/usr/bin/env python3
"""Parse shortcuts.vdf (binary) and output: appid|name|exe|startdir per shortcut.
Uses pattern search for robustness. Resolves /root to steam_home."""
import sys
import struct

def main():
    if len(sys.argv) < 2:
        return
    path = sys.argv[1]
    steam_home = sys.argv[2] if len(sys.argv) > 2 else "/userdata/system/add-ons/steam"

    try:
        with open(path, 'rb') as f:
            data = f.read()
    except OSError:
        return

    # Find each "\x02appid\x00" (type uint32, key appid) - 4 bytes LE follow
    marker = b'\x02appid\x00'
    pos = 0
    while True:
        idx = data.find(marker, pos)
        if idx < 0:
            break
        val_pos = idx + len(marker)
        if val_pos + 4 > len(data):
            break
        appid, = struct.unpack_from('<I', data, val_pos)
        pos = val_pos + 4

        # Find AppName (type 01, key AppName - format: type key\0 value\0)
        aname_idx = data.find(b'\x01AppName\x00', val_pos)
        if aname_idx < 0 or aname_idx > val_pos + 200:
            name = "Unknown"
        else:
            s_start = aname_idx + 9  # after \x01AppName\x00
            s_end = data.find(b'\x00', s_start)
            name = data[s_start:s_end].decode('utf-8', errors='replace') if s_end >= 0 else "Unknown"

        # Find Exe
        exe_idx = data.find(b'\x01Exe\x00', val_pos)
        if exe_idx < 0 or exe_idx > val_pos + 300:
            continue
        exe_start = exe_idx + 5  # after \x01Exe\x00
        exe_end = data.find(b'\x00', exe_start)
        exe = data[exe_start:exe_end].decode('utf-8', errors='replace').strip('"') if exe_end >= 0 else ""

        # Find StartDir (type byte may vary; search for key)
        sdir_idx = data.find(b'StartDir\x00', val_pos)
        if sdir_idx < 0 or sdir_idx > val_pos + 400:
            start = ""
        else:
            s_start = sdir_idx + 9  # after StartDir\x00
            s_end = data.find(b'\x00', s_start)
            start = data[s_start:s_end].decode('utf-8', errors='replace') if s_end >= 0 else ""

        if exe:
            if exe.startswith('/root/'):
                exe = steam_home + exe[5:]
            if start.startswith('/root/'):
                start = steam_home + start[5:]
            print(f"{appid}|{name}|{exe}|{start}")

if __name__ == '__main__':
    main()
