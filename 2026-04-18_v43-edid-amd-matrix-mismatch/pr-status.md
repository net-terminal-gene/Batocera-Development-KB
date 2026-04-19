# PR Status — v43 EDID Wrong Matrix on AMD Re-Install

## No PR yet

Investigation phase. **Mode-switcher** work ( **`Boot_*`** sidecar + **`03_backup_restore`** + dual-boot stack) is one commit on fork branch **`crt-hd-mode-switcher-v43`** (**`aa3a733`**, pushed **2026-04-19**); land via **#390** / **#395** as appropriate. **EDID-matrix** external report still needs tester logs.

Related work:
- PR [#390](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/390) — HD/CRT Mode Switcher
- PR [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) — v43 branch (includes Wayland/X11 dual-boot work; **this KB session’s hardware testing is X11-only**, not dual-boot Wayland validation)
