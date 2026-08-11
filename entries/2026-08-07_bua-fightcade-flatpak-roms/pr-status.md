# PR Status — Fightcade Flatpak (Flathub) — Missing ROMs Directory

**Not BUA Wine Fightcade.** This session tracks **Flathub `com.fightcade.Fightcade`** on Batocera. BUA Switchres for Wine Fightcade is separate (**PR #156**, merged 2026-05-11).

## Published repo (2026-08-09 → 2026-08-11 beta)

- Repo: [net-terminal-gene/batocera-fightcade-flatpak](https://github.com/net-terminal-gene/batocera-fightcade-flatpak) (public)
- Delivery: `curl | bash` install script (no PR into BUA or batocera.linux)
- Current `main`: `09e216f` — `feat: HD video presets, auto-resolution patch, and menu cursor fixes`
- Prior milestones: `9a44f14` initial release; `aae14c5` gamepad + CRT hostd + docs

## Shipped (2026-08-11)

| Area | Status |
|------|--------|
| ROM symlinks from `/userdata/roms` | ✅ install + `fightcade-roms-sync` |
| Flatpak filesystem overrides | ✅ |
| Ports ES artwork + gamelist | ✅ |
| Gamepad lobby / menu navigation | ✅ `input/fightcade-pad-mouse` |
| HD video presets (FBNeo, SNES9x, Flycast) | ✅ `hd/patch-hd-video.sh` + auto-resolution |
| CRT Switchres wrapper (xorg) | ✅ `crt/fightcade-crt-switchres` + hostd (BUA-model, Flatpak xdg-open patch) |
| Diagnostics | ✅ `fightcade-diagnose` |
| Docs | ✅ README, `docs/CRT.md`, `docs/discord-beta-announcement.md` |

**CRT prerequisite:** [Batocera-CRT-Script](https://github.com/ZFEbHVUE/Batocera-CRT-Script) installed and configured.

**Does not modify Fightcade client UI.** Switchres is a gameplay wrapper around stock Flatpak Fightcade.

## Validation

| Path | Host | Notes |
|------|------|-------|
| HD install + ROM sync + HD video | batocera.local | ✅ 2026-08-09 wipe + reinstall; ✅ 2026-08-10 HD FBNeo/SNES/Flycast tweaks |
| CRT Switchres ONLINE MATCH | — | **TBD** — needs CRT tester |
| CRT Switchres REPLAY | — | **TBD** |
| CRT Switchres LIVE SPECTATING | — | **TBD** |
| `curl \| bash` from GitHub on fresh box | — | **TBD** community beta |

## Beta call (2026-08-11)

Public beta announcement drafted: repo `docs/discord-beta-announcement.md`. Seeking CRT testers for ONLINE MATCH, REPLAY, and LIVE SPECTATING Switchres behavior.

## Outstanding

- End-to-end CRT Switchres matrix on real CRT hardware (not only HD lobby on batocera.local)
- Fresh-install validation via raw GitHub one-liner on a second machine
- Close session with VERDICT when beta testing is satisfied
