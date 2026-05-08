# Research — BUA Steam: Launcher Retry Logic

## Findings

### lbfix.sh Behavior

- Waits for `pinned_libs_64/libcurl.so.4` to appear as symlink or file
- If symlink: deletes it, downloads replacement from GitHub
- Self-deletes after running (`rm -- "$0"`)
- Only runs once (first launch ever); subsequent launches skip it (file gone)

### Source

```bash
TARGET="/userdata/system/add-ons/steam/.local/share/Steam/ubuntu12_32/steam-runtime/pinned_libs_64/libcurl.so.4"
URL="https://github.com/batocera-unofficial-addons/batocera-unofficial-addons/raw/main/steam/extra/libcurl.so.4"

while [[ ! -L "$TARGET" && ! -f "$TARGET" ]]; do sleep 2; done

if [[ -L "$TARGET" ]]; then
    rm -f "$TARGET"
    curl -L -o "$TARGET" "$URL"
fi

rm -- "$0"
```

### Why It Exists

The bundled libcurl.so.4 in Steam's runtime has an OpenSSL version mismatch that causes HTTPS failures on some Batocera builds. The fix replaces it with a CURL_OPENSSL_4-compatible version.

### RunImage Behavior After Crash

- RunImage binary (`/userdata/system/add-ons/steam/steam`) mounts itself via dwarfs FUSE at `/tmp/.mount_steamremp*`
- After `pkill -f steam`, the dwarfs mount is unmounted (verified: no stale mount)
- But the binary refuses to re-mount on next invocation (silent exit, no error)
- Possible lock file or state detection in RunImage preventing double-mount
- Third launch works after manual process cleanup (kill stuck Launcher/emulatorlauncher)

### Related: PR #146

PR #146 adds `XAUTHORITY=/var/run/xauth` and broader wmctrl regex. This fixes a different issue (wmctrl can't connect to X11 on AMD systems). Does NOT fix the lbfix crash.
