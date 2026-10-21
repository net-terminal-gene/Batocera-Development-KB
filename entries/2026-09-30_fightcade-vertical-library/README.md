# Fightcade Vertical Library Genre Filter

**Session:** `2026-09-30_fightcade-vertical-library`
**Status:** MERGED via PR #4 (2026-10-09, `fa05fd5`)
**Primary repo:** net-terminal-gene/batocera-fightcade-flatpak
**PR:** [#4](https://github.com/net-terminal-gene/batocera-fightcade-flatpak/pull/4) — see [pr-status.md](pr-status.md)

## What this is

Adds a **Vertical** entry to Search → Genre in the Fightcade lobby (CRT vertical mode only). The list is the local allowlist (`window.__FC_VERTICAL_IDS`, 593 game ids in `research/vertical-matches.md` after stripping 144 titles whose preview PNG returns HTTP 404). It is drawn immediately. Join looks up that one game with a single `channels` request, then sends Join with the server's channel name. Vertical sits in alphabetical order in the genre menu (before W).

The earlier design paged `{ req: "channels", all: true }` across the whole library on the lobby socket. That flood made the server answer `too many requests`, so Join failed until the dump finished and the rate limit cooled. Hardware check 2026-10-01: list in the same millisecond, three joins (`1945kiii`, `1943kai`, `zzyzzyxx`) each `200` in about 0.4s. Commit `719990f` on PR #4.

Shares branch `vertical-build` and PR #4 with `2026-09-30_fightcade-css-vertical-mode`.

## Where to look

| File / folder | Purpose |
|---------------|---------|
| [plan.md](plan.md) | Problem, approach, files touched, validation checklist |
| [VERDICT.md](VERDICT.md) | Final outcome when the session closes |
| [pr-status.md](pr-status.md) | PR #4, branch `vertical-build` |
| [research/vertical-matches.md](research/vertical-matches.md) | 593 Fightcade game ids (preview-present) |
| [research/nopreview-list.md](research/nopreview-list.md) | 144 ids stripped for 404 previews |
| [design/README.md](design/README.md) | Page-world WS intercept + inject |
| [debug/README.md](debug/README.md) | Test logs and failure signs |
