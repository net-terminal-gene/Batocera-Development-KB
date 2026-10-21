# 2026-10-01 — Join refused while Vertical downloaded the library

Hardware: batocera.local. Log: `/userdata/system/fightcade-flatpak/lobby/fc-cta.log`.

## What failed

Other genre filters send one paginated `channels` request (about 50 games) and Join works immediately. Vertical is not a server genre. The old script replaced that request with `{ req: "channels", all: true }` and paged the entire library on the same socket.

Clicking Join while that dump was recent got `result: 400`, `error: "too many requests"`. The card was a real channel (`1943kai`, `liveApi: true`). Role and channel cap were fine (2 of 3 open). The server refused the join.

A later visit, after the dump had finished and was cached, joined Agent Super Bond with `result: 200`.

Retrying the refused join (1.5s, 3s, 6s, 8s) made it worse. Four overlapping retry chains (1941, 1942, 1943 Kai, 1943) kept the socket busy. Every reply stayed `400` for about 40 seconds. No room was added.

## What shipped

`719990f`. The list is the local allowlist (593). Join does one `channels` lookup for that gameid, then sends Join with the server name.

Relaunch 2026-10-01 17:48 UTC:

| Step | Result |
|------|--------|
| Vertical click 17:49:01.046 | `vertical-list` count 593, source allowlist, 1 ms later |
| 1945k III | lookup `1945kiii` → join `1945k III (newer, OPCX2 PCB)` → `200` in ~0.4s |
| 1943 Kai | lookup `1943kai` → join `1943 Kai: Midway Kaisen (Japan)` → `200` in ~0.4s |
| Zzyzzyxx | lookup `zzyzzyxx` → join `Zzyzzyxx (set 1)` → `200`, then `join-room true` |

No `too many requests` in that run.

## Genre order

Vertical had been `push`ed onto the end of `vm.genres`. `placeVertical()` inserts it before the first genre that sorts after `"Vertical"` (before W). Needs a Fightcade relaunch to show in the open menu.
