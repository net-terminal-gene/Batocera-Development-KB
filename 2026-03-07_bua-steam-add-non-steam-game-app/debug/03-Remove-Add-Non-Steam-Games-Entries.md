# 03 — Remove Add Non-Steam Games Entries (Start Over)

Use this when you need to remove games that were added by the Add Non-Steam Games app from ES > Steam, so you can start over (e.g. re-run the app with different exe choices).

**Pre-update workflow:** Before testing script changes, remove the test games so the full flow (scan → pick → add) can be exercised.

## How Add Non-Steam Games Creates Entries

- **Launchers:** `{shortcut_id}_{slug}.sh` and `{shortcut_id}_{slug}.sh.keys` in the Steam ROMs folder
- **shortcut_id:** CRC32 of exe path, OR'd with 0x80000000 (e.g. `3672483792`, `2654906105`)
- **slug:** Game name with spaces→underscores, alphanumeric only (e.g. `Infinos2`, `TestTwoExes`)
- **gamelist.xml:** Each game gets a `<game>` block with `<path>./{shortcut_id}_{slug}.sh</path>`, `<genre>Non-Steam</genre>`

## Step 1: Determine ROMs Path

On Batocera, the Steam ROMs folder may be:

- `/userdata/.roms_base/steam` — when mergerfs is used (`.roms_base` exists)
- `/userdata/roms/steam` — when mergerfs is not used

```bash
# On Batocera (or via ~/bin/ssh-batocera.sh)
test -d /userdata/.roms_base && echo "ROMS=/userdata/.roms_base/steam" || echo "ROMS=/userdata/roms/steam"
```

## Step 2: Find Add Non-Steam Games Entries

```bash
# List gamelist entries with genre Non-Steam
grep -B1 -A2 'genre>Non-Steam' $ROMS/gamelist.xml

# Or list launchers with CRC32-style IDs (8+ digit number prefix)
ls -la $ROMS/[0-9]*_*.sh 2>/dev/null
```

Known test entries (from this session):

| Game       | Launcher                    |
|-----------|-----------------------------|
| Infinos2  | 3672483792_Infinos2.sh     |
| TestTwoExes | 2654906105_TestTwoExes.sh |
| TestTwoExes (duplicate) | `_3486426756|TestTwoExes.sh` |

To discover all current entries: `grep -E 'path|genre.*Non-Steam' $ROMS/gamelist.xml`

## Step 3: Remove Launcher Files

```bash
ROMS=/userdata/.roms_base/steam   # or /userdata/roms/steam

rm -f $ROMS/3672483792_Infinos2.sh $ROMS/3672483792_Infinos2.sh.keys
rm -f $ROMS/2654906105_TestTwoExes.sh $ROMS/2654906105_TestTwoExes.sh.keys
# Malformed path (if present):
rm -f "$ROMS/_3486426756|TestTwoExes.sh" "$ROMS/_3486426756|TestTwoExes.sh.keys" 2>/dev/null
```

If you have other Add Non-Steam Games entries, add their `{id}_{slug}.sh` and `.keys` to the `rm` commands.

## Step 4: Remove Gamelist Entries

Use `xmlstarlet` to delete the `<game>` nodes whose `<path>` matches:

```bash
xmlstarlet ed \
  -d '//game[path="./3672483792_Infinos2.sh"]' \
  -d '//game[path="./2654906105_TestTwoExes.sh"]' \
  -d '//game[path="./_3486426756|TestTwoExes.sh"]' \
  $ROMS/gamelist.xml > /tmp/gamelist.xml.tmp && mv /tmp/gamelist.xml.tmp $ROMS/gamelist.xml
```

**Note:** Add one `-d '//game[path="./{exact_path}"]'` per entry. The path must match exactly (including `./` prefix).

## Step 5: Reload ES Game List

```bash
curl -s http://127.0.0.1:1234/reloadgames
```

## One-Liner (Known Test Games)

```bash
ROMS=/userdata/.roms_base/steam
test -d /userdata/.roms_base || ROMS=/userdata/roms/steam
rm -f $ROMS/3672483792_Infinos2.sh $ROMS/3672483792_Infinos2.sh.keys \
      $ROMS/2654906105_TestTwoExes.sh $ROMS/2654906105_TestTwoExes.sh.keys
xmlstarlet ed -d '//game[path="./3672483792_Infinos2.sh"]' \
             -d '//game[path="./2654906105_TestTwoExes.sh"]' \
             -d '//game[path="./_3486426756|TestTwoExes.sh"]' \
  $ROMS/gamelist.xml > /tmp/gamelist.xml.tmp && mv /tmp/gamelist.xml.tmp $ROMS/gamelist.xml
curl -s http://127.0.0.1:1234/reloadgames
echo Done
```

## Via SSH from Mac

```bash
~/bin/ssh-batocera.sh "ROMS=/userdata/.roms_base/steam; test -d /userdata/.roms_base || ROMS=/userdata/roms/steam; rm -f \$ROMS/3672483792_Infinos2.sh \$ROMS/3672483792_Infinos2.sh.keys \$ROMS/2654906105_TestTwoExes.sh \$ROMS/2654906105_TestTwoExes.sh.keys; xmlstarlet ed -d '//game[path=\"./3672483792_Infinos2.sh\"]' -d '//game[path=\"./2654906105_TestTwoExes.sh\"]' \$ROMS/gamelist.xml > /tmp/gamelist.xml.tmp && mv /tmp/gamelist.xml.tmp \$ROMS/gamelist.xml; curl -s http://127.0.0.1:1234/reloadgames; echo Done"
```

**SSH quoting:** The expect-based `ssh-batocera.sh` may mangle complex quoting. If the one-liner fails, run the commands interactively: `~/bin/ssh-batocera.sh` (no args) to get a shell, then paste the commands.

**Note:** `xmlstarlet` is not installed on Batocera. Use the Python method below instead when running via SSH.

### Via SSH from Mac (Python method)

Batocera has `python3` but not `xmlstarlet`. Use the script in `batocera-unofficial-addons/steam/extra/remove-add-non-steam-entries.py`:

```bash
B64=$(base64 -i batocera-unofficial-addons/steam/extra/remove-add-non-steam-entries.py | tr -d '\n')
~/bin/ssh-batocera.sh "echo $B64 | base64 -d > /tmp/rem.py && python3 /tmp/rem.py"
```

The script discovers all Non-Steam entries in gamelist.xml, removes launcher `.sh` and `.keys` files, edits gamelist via `xml.etree.ElementTree`, and calls `reloadgames`.

## Game Source Folders (Not Removed)

The script does **not** remove the game source folders in `/userdata/system/add-ons/steam/non-steam-games/`. Those stay so you can re-run Add Non-Steam Games. To remove them too:

```bash
rm -rf /userdata/system/add-ons/steam/non-steam-games/Infinos2
rm -rf /userdata/system/add-ons/steam/non-steam-games/TestTwoExes
```
