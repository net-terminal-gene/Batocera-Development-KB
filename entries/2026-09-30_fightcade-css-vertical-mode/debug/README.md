# Debug — Fightcade Flatpak CSS Vertical (TATE) Lobby Mode

## Deploy loop

```bash
# Source of truth on device: /userdata/system/fightcade-flatpak/
~/bin/rsync-batocera.sh /Users/mikey/batocera-fightcade-flatpak/lobby/inject.js \
    root@batocera.local:/userdata/system/fightcade-flatpak/lobby/inject.js
~/bin/rsync-batocera.sh /Users/mikey/batocera-fightcade-flatpak/lobby/inject.css \
    root@batocera.local:/userdata/system/fightcade-flatpak/lobby/inject.css
# Install into the nativefier app's inject/ dir:
~/bin/ssh-batocera.sh 'bash /userdata/system/fightcade-flatpak/fightcade-lobby-vertical apply'
# inject.css is cached at startup -> full relaunch needed:
~/bin/ssh-batocera.sh "pkill -f 'fc2-electron --disable-gpu-sandbox'; sleep 1; \
    xdotool windowactivate 10485771; xdotool key --window 10485771 Return"
```

Notes: `pkill` of the app returns SSH exit 255 but works. ES window id 10485771. `inject.js` is
re-required each page load; `inject.css` needs the relaunch. `rsync-batocera.sh` occasionally errors
`io_read_flush` transiently right after a relaunch — retry once the app has settled.

## Screenshot loop (upright)

```bash
~/bin/ssh-batocera.sh 'F=/userdata/screenshots/x.png; \
  DISPLAY=:0 ffmpeg -y -f x11grab -video_size 641x480 -i :0.0+0,0 -vframes 1 "$F" </dev/null >/dev/null 2>&1; \
  base64 "$F"' | python3 -c "import sys,base64,io;from PIL import Image;\
b=[l for l in sys.stdin.read().splitlines() if l and 'password' not in l.lower() and not l.startswith('root@')];\
Image.open(io.BytesIO(base64.b64decode(''.join(b)))).transpose(Image.ROTATE_90).save('/tmp/shot.png')"
```

Raw framebuffer is landscape 641×480; rotate `ROTATE_90` to view upright. In a raw shot, page content
reads sideways and OS-painted UI (native menu bar) reads horizontally — a quick way to tell native vs
in-page.

## Zoom persistence checks

```bash
# Live vertical zoom file (written the instant zoom changes):
~/bin/ssh-batocera.sh 'cat /userdata/system/fightcade-flatpak/lobby-zoom-vertical'
# lobby-zoom buckets + Preferences + mode:
~/bin/ssh-batocera.sh 'bash /userdata/system/fightcade-flatpak/fightcade-lobby-zoom status'
~/bin/ssh-batocera.sh 'bash /userdata/system/fightcade-flatpak/fightcade-lobby-zoom detect'  # -> crt_vertical
tail -20 /tmp/fightcade-lobby-zoom.log   # on device
```

Verified: file shows factor live (e.g. `1.1`), unchanged timestamp after exit (survives kill); vertical
`apply`/`save` log "zoom handled by lobby inject.js; skipping".

## FBNeo rotation restore (function test on real config copies)

```bash
~/bin/ssh-batocera.sh 'set -e
DIR=.../config/fcadefbneo; T=/tmp/rottest; rm -rf $T; mkdir -p $T
cp "$DIR/fcadefbneo.ini" $T/t.ini; sed -i "s/^nVidRotationAdjust .*/nVidRotationAdjust 1/" $T/t.ini
cp "$DIR/fcadefbneo.ini.bak.switchres" $T/t.ini.bak.switchres
eval "$(sed -n "/^restore_ini() {/,/^}/p" /userdata/system/fightcade-flatpak/crt/fightcade-crt-switchres)"
restore_ini $T/t.ini
grep nVidRotationAdjust $T/t.ini; grep nVidHorWidth $T/t.ini'   # rot=1 preserved, HorW reverted
```

## Failure signs

| Symptom | Likely cause |
|---------|--------------|
| Tooltip / cursor / dropdown faces sideways | OS-painted in screen space; needs in-page overlay, not CSS on the native element |
| Members list covers whole screen | `.usersListWrapper` `position:fixed`/`width:320px` not overridden |
| Menu pushed off screen, can't close app | webFrame zoom not folded into fit; recover with `pkill -f 'fc2-electron --disable-gpu-sandbox'` |
| Zoom resets on relaunch (vertical) | not reading `lobby-zoom-vertical` on load, or file not written on change |
| Zoom resets on relaunch (landscape) | Chromium Preferences debounce (still on that path) |
| FBNeo rotation reverts each launch | `restore_ini` wiping `nVidRotationAdjust` (CRT switchres) |
