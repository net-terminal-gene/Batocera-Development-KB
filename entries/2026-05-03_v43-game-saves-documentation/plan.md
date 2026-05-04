# v43 game saves layout (documentation for upstream)

**Image line:** All SSH findings in this session are from the **Batocera x86_64** (PC) image. They are **not** from the **Zen3**-specific Batocera image; path or packaging differences on Zen3 are out of scope unless we capture a separate host.

## Agent/Model scope

Composer; discovery via `~/bin/ssh-batocera.sh` on reflashed **v43 x86_64** and on **v42 x86_64**. Steam↔ES regression fully documented in **`research/steam-es-batocera-steam-update-regression.md`** (commit **`ab1a8b85f9`**). User to re-confirm on v43 hardware using checklist in that file.

## Problem

1. **Original scope:** Map **where v43 persists userdata / saves** vs v42 for upstream (see **`v42-x86_64-snapshot.md`**).
2. **Additional finding:** **Steam games not appearing in ES on v43** is explained by **`batocera-steam-update`** scanning **`flatpak/data/Desktop/`** after upstream commit **`ab1a8b85f9`**, while **v42’s deployed script still scans `.../.local/share/applications`**, and Flatpak Steam commonly places game **`.desktop`** files under **`applications`**, not **`Desktop`**.

## Root cause

| Topic | Status |
|--------|--------|
| Saves partition layout v42 vs v43 | Same canonical **`/userdata/saves`** model; big **`du`** differences were **fresh vs long-used** installs (see **`v42-x86_64-snapshot.md`**). |
| Steam missing in ES on v43 | **`steam_apps_dir`** path change in **`ab1a8b85f9`** (`applications` → **`Desktop/`**) vs where Steam actually drops **`*.desktop`** files on tested hosts. **Full write-up:** **`research/steam-es-batocera-steam-update-regression.md`**. |

## Solution approach

1. ~~Document v43 paths~~ Done.
2. ~~v42 snapshot~~ Done.
3. ~~User: **confirm on v43** using checklist in **`steam-es-batocera-steam-update-regression.md`**.~~ Done (incl. **Animal Well** on patched **`batocera-steam-update`**).
4. ~~Upstream **PR**~~ **[#15670](https://github.com/batocera-linux/batocera.linux/pull/15670)** (**OPEN** on GitHub as of 2026-05-04; approved, merge to **master** pending). Optional GitHub issue no longer needed for the dual-path fix.

## Files touched

| Repo | File | Change |
|------|------|--------|
| Batocera-Development-KB | `research/steam-es-batocera-steam-update-regression.md` | New: Steam↔ES regression |
| Batocera-Development-KB | `research/v42-x86_64-snapshot.md`, `research/README.md`, `plan.md` | Steam path note + links |
| Batocera-Development-KB | `VERDICT.md`, `pr-status.md` | Close-out + **PR #15670** tracking |
| Vault-Batocera | `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md`, `wiki/sources/batocera-development-kb.md`, `_hot.md`, `log.md` | Session status + KB table |

## Validation checklist

- [x] v42 SSH: same `batocera-version`, `df`, `/userdata/saves` tree, `batocera.conf` storage keys, `.roms_base` (see **`research/v42-x86_64-snapshot.md`**).
- [x] **v43 re-confirm:** `sed -n '60,70p' /usr/bin/batocera-steam-update` + `ls` **`Desktop`** vs **`applications`** (see **`research/steam-es-batocera-steam-update-regression.md`** — **Live v43 re-confirmation**).
- [ ] Controlled same-disk v42→v43 upgrade diff (optional; not done).
- [ ] One-paragraph “for devs” summary in `VERDICT.md` when you are ready to close the session.
