# VERDICT — v43 EDID Wrong Matrix on AMD Re-Install

## Status: **PARTIAL** (local lab closed; external report still open)

| Track | Result |
|-------|--------|
| **Local AMD lab (X11-only, debug `00`–`10`)** | **No EDID matrix bug reproduced.** Install and HD↔CRT mode switcher behave consistently with v43 design. |
| **Tester (RX6400, re-install after round trip)** | **Not verified here.** Needs their `BUILD_15KHz_Batocera.log` (`EDID build:`, `TYPE_OF_CARD`), `BootRes.log`, `edid-decode`, file mtime. |

## Summary

On a **Navi 32 (RX 7700/7800 XT)** system, **Batocera 43**, **X11-only** (no Wayland dual-boot):

1. **Installer** — Choosing **`generic_15`** shows the **native** resolution list (**320 / 640 / 768**), not the **1280×** superres list. **`BUILD_15KHz_Batocera.log`** records **`EDID build: switchres 769 576 25 -f 769x576@25 -i switchres.ini -e`** with **`TYPE_OF_CARD='AMD/ATI'`**, **`IFE=1`**, **DCN**. **`edid-decode`** matches **AMD-native** expectations (no **1280×240** preferred DTD). This is consistent across **first CRT boot ([02](debug/pre-fix/02-crt-mode-pre-mode-switcher.md))** and **after full HD↔CRT cycles ([07](debug/pre-fix/07-crt-mode-pre-mode-switcher.md))**.

2. **Mode switcher** — Does **not** call **`switchres -e`** for **`generic_15.bin`**; EDID regeneration is **only** from the **install script** (and geometry tool). So the tester’s **changed EDID after a re-install** points at **`Batocera-CRT-Script-v43.sh`**, not at mode switcher modules.

3. **769×576 width** — **Not** proof of the NVIDIA-only branch. v43 applies an **EDID horizontal pre-bump** for **AMD/ATI** as well (~`Batocera-CRT-Script-v43.sh` ~3640). Use **`edid-decode`** + **`EDID build:`** line to judge matrix, not width alone ([05](debug/pre-fix/05-mode-switcher-hd-to-crt-no-boot-recognition.md), [research](research/README.md)).

4. **“Why do I have to pick CRT boot again?”** — **Expected** when **`global.videomode=default`** in HD mode: live **`batocera.conf`** has no **`Boot_*`** line. **`mode_backups/`** under **`Batocera-CRT-Script-Backup`** is the switcher’s persisted triple; after the **first** full save from HD mode, **`Config check`** can show **Boot** populated ([05](debug/pre-fix/05-mode-switcher-hd-to-crt-no-boot-recognition.md), [10](debug/pre-fix/10-mode-switcher-hd-to-crt-pre-reboot.md)). This is **workflow / clarity**, not an EDID corruption bug.

**Conclusion:** In this lab, **nothing is wrong** with the **AMD matrix branch** or **mode switcher** regarding **wrong superres EDID**. The **external** report remains **unexplained** until the same evidence is captured on the failing machine.

## Plan vs reality

| Original hypothesis | Lab outcome |
|--------------------|-------------|
| Mode switcher corrupts EDID | **Rejected** for X11 path (no **`switchres -e`** for **`generic_15.bin`** in modules). |
| Installer takes wrong branch on AMD | **Not reproduced** on RX 7700/7800 lab; **`EDID build:`** stays **769 576 25**, not **1280**. |
| Tester’s symptom | **Still possible** via **(a)** stale **`generic_15.bin`**, **(b)** failed **`TYPE_OF_CARD`** on that run, **(c)** environment not yet replicated. |

## Root causes

**Local lab**

1. **None found** for “wrong superres matrix on AMD after install” on tested hardware and flow.

**Tester (pending)**

1. **TBD** — Requires logs to distinguish detection bug, stale file, or misread symptom.

## Changes Applied

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | — | **None** (investigation only). |

## What would change the verdict

- Tester supplies **`grep` / `edid-decode` / mtime** showing **`EDID build: switchres 1280 …`** with **`TYPE_OF_CARD=AMD/ATI`**, or a **repro** on a second machine.
- Optional: **docs** or **UI copy** in mode switcher explaining **`mode_backups/`** vs **`batocera.conf`** (not a code fix for EDID).

## Models / session

- Investigation and debug notes: Composer + SSH snapshots ([`debug/pre-fix/00`–`10`](debug/pre-fix/), 2026-04-18–19); post-fix logs in [`debug/fix/`](debug/fix/).
