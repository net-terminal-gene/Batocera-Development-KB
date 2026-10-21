# Design — Fightcade Vertical Library Genre Filter

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Electron isolated world (inject.js)                         │
│  - applyFit() → setupVerticalSearch()                       │
│  - Reads vertical-allowlist.js + vertical-search.js via fs  │
│  - Appends <script> elements → page world execution         │
└───────────────────┬─────────────────────────────────────────┘
                    │ <script> injection
┌───────────────────▼─────────────────────────────────────────┐
│ Page world                                                  │
│  vertical-allowlist.js  → window.__FC_VERTICAL_IDS {}       │
│  vertical-search.js:                                        │
│    - Poll .filterItem.genre → insert "Vertical" in sort     │
│      order (before the first genre that sorts after it)    │
│    - Hook WebSocket.prototype.send                          │
│    - Hook WebSocket constructor (new sockets get tap)       │
│    - Hook WS.prototype.dispatchEvent (pre-existing sockets) │
└───────────────────┬─────────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────────┐
│ Data flow (2026-10-01, commit 719990f)                      │
│                                                             │
│  Vue onChangeFilter()                                       │
│    → WS send { req:"channels", genre:"Vertical", idx:N }   │
│       ↓ intercepted. Not sent to the server.               │
│    → dispatchEvent synthetic reply from __FC_VERTICAL_IDS  │
│       (593 cards, immediately)                             │
│                                                             │
│  Join click on a card                                       │
│    → hold the join                                          │
│    → one { req:"channels", filter:gameid, paginated, page:0 }│
│    → if that page has the gameid, send join with channel.name│
│    → else retry the lookup with the allowlist title        │
│    → cache the server name for the next join of that game  │
└─────────────────────────────────────────────────────────────┘
```

## Key contracts

| Component | Responsibility |
|-----------|---------------|
| `vertical-allowlist.js` | Provides `window.__FC_VERTICAL_IDS` — one key per Fightcade gameid |
| `vertical-search.js` | Genre insert, local allowlist list, one-game lookup on Join |
| `inject.js` `setupVerticalSearch()` | Reads source files from `/userdata/system/fightcade-flatpak/lobby/` via `require("fs")` and injects as `<script>` tags |
| `fightcade-lobby-vertical apply` | Copies `inject.js`/`inject.css` to app inject dir; source files stay in lobby/ |

## Why page world

Fightcade's `WebSocket` instance lives in the page world. Nativefier's inject scripts run in
Electron's isolated world where `window.WebSocket` is a different object. Hooks on the isolated-
world `WebSocket` prototype are invisible to the page. The `<script>` tag injection from inject.js
puts code into the page world where the real socket lives.

## Allowlist source

`scripts/gen-vertical-allowlist.py` parses `research/vertical-matches.md` for all backtick-quoted
second-column table cells (the Fightcade zip ids) and generates `lobby/vertical-allowlist.js`.
Re-run when the KB list changes.
