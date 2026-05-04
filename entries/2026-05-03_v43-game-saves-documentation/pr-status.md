# PR Status — v43 game saves layout

**Host:** v43 **x86_64** capture (not Zen3).

## batocera.linux — Steam ↔ ES (`batocera-steam-update`)

| PR | Title | Merge |
|----|--------|--------|
| [#15670](https://github.com/batocera-linux/batocera.linux/pull/15670) | batocera-steam-update: support both Desktop/ and .local/share/applications for game shortcuts | **MERGED** 2026-05-04 (`mergedAt` 09:33 UTC); merge commit **`b27ce08ab3833be9b8e5432d5882a6f66d0c1d2a`** |

**Notes:** **`find`** runs over **`/userdata/saves/flatpak/data/Desktop`** and **`.../.var/app/com.valvesoftware.Steam/.local/share/applications`** when each directory exists.

**Regression commit (context):** `ab1a8b85f913d126162492c9b2aa468f6dfb3122` (Desktop-only scan).
