# Research — Fightcade Vertical Library Genre Filter

## Findings

- Allowlist source: `vertical-matches.md` (593 ids). FBNeo 556 + 1 alt id, NAOMI 12, Super NES 8, PC Engine 16. NES and Mega Drive are 0 after cleanup.
- Preview rule (user): only drop games whose Fightcade card preview is missing. URL is `https://web.fightcade.com/static/previews/{gameid}.png`. HTTP 404 = "NO PREVIEW AVAILABLE" and Join does not work.
- Probe: 12-worker ThreadPoolExecutor over the pre-strip set (737). Result: 144 missing PNGs, listed in `nopreview-list.md`. Those ids were removed from the allowlist and regenerated into `lobby/vertical-allowlist.js`.
- Do not use "not in the All Games API page" as a delete signal. Frogger and Gaiapolis have artwork and were false SUSPECT flags.
- Dreamcast vertical titles are covered by NAOMI / FBNeo copies, not the Fightcade Dreamcast fighter/sports folder.
- `ddpdoj` (DoDonPachi Dai-Ou-Jou) is vertical MAME, not this Fightcade FBNeo folder.
