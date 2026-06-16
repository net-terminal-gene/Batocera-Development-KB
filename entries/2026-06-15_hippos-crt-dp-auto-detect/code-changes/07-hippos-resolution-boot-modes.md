# 07 — hippos-resolution: listCrtBootModes helper

**File:** `overlays/rootfs/usr/lib/hippos/hippos-resolution`

New subcommand for ES to populate **BOOT RESOLUTION** picker filtered by monitor profile.

## Existing CRT hooks in same file

```bash
_crt_active() { [[ -f /etc/switchres.ini ]]; }

_crt_restore() {
    boot_res="$(hippos-settings get crt.boot_resolution 2>/dev/null || echo '640x480i')"
    w="${boot_res%%x*}"
    rest="${boot_res#*x}"
    h="${rest%%[i@]*}"
    ...
    switchres "${w}" "${h}" "${hz}" 2>/dev/null || ...
}
```

## Recommended: `listCrtBootModes`

Add case arm (pseudo — implementer fills profile matrix):

```bash
    listCrtBootModes)
        PROFILE="${2#--profile=}"
        PROFILE="${PROFILE:-$(hippos-settings get crt.monitor_profile 2>/dev/null)}"
        PROFILE="${PROFILE:-generic_15}"

        _emit_boot_mode() {
            # $1=stored value (hippos.conf)  $2=UI label
            printf '%s:%s\n' "$1" "$2"
        }

        case "${PROFILE}" in
            generic_15|ntsc|pal|arcade_15)
                _emit_boot_mode "640x480i"  "640x480i @ 15 kHz"
                _emit_boot_mode "640x480"   "640x480p @ 15 kHz"
                _emit_boot_mode "768x576i"  "768x576i @ 15 kHz"
                ;;
            arcade_15_25_31|arcade_15_25|arcade_15_31)
                for band in 15 25 31; do
                    _emit_boot_mode "640x480i@${band}k"  "640x480i @ ${band} kHz"
                    _emit_boot_mode "640x480@${band}k"   "640x480p @ ${band} kHz"
                done
                _emit_boot_mode "768x576i@15k" "768x576i @ 15 kHz"
                ;;
            arcade_25)  ... ;;
            arcade_31)  ... ;;
            *)
                _emit_boot_mode "640x480i" "640x480i @ 15 kHz (default)"
                ;;
        esac
        ;;
```

**Storage format:** Either extend `hippos-crt-setup` to parse `@15k` / band suffix, or map UI labels to existing `640x480i` + rely on profile ranges only for 15k-only profiles. For multisync boot-at-31k, switchres must generate 31 kHz menu modeline — verify against `videomodes.conf_${PROFILE}` and switchres `-c` output before locking format.

## Profile → videomodes source files

```
/usr/share/hippos/crt/videomodes/amd/videomodes.conf_generic_15
/usr/share/hippos/crt/videomodes/amd/videomodes.conf_arcade_15_25_31
...
```

Consider generating boot mode list from a small manifest YAML per profile instead of hardcoding in bash.

## ES consumption

Mirror `listModes` pattern in `ApiSystem.cpp`:

```cpp
executeEnumerationScript("hippos-resolution listCrtBootModes --profile=" + profile);
```

Parse `stored:label` lines into OptionListComponent entries.
