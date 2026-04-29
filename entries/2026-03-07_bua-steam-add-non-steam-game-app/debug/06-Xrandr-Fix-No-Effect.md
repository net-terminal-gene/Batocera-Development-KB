# 06 — Xrandr Post-Exit Fix: No Effect

**Date:** 2026-03-07  
**Hypothesis:** Display not restored after pygame quit; ES running but not visible due to bad resolution/state.

**Fix tried:** Add `xrandr -display :0.0 --output DP-1 --mode 641x480` to the launcher after Python exits, before script returns. Applied in deploy-add-non-steam-games.sh and steam2.sh.

**Result:** Same behavior. Cancel still does not return to ES. xrandr post-exit did not fix it.

**Implication:** Display restore is not the root cause. ES is running (confirmed via `ps`). Something else keeps ES from being visible — e.g. window focus, X11 stacking, or a different display/state issue.

**Next:** Need to compare with a working app (BUA installer, another Steam utility) on the same system. Or try focus/raise (xdotool/wmctrl not on Batocera). Or investigate emulatorlauncher/videoMode interaction.

---

**Update:** BUA installer also does not return to ES on this system. **Not app-specific** — Pygame apps launched via emulatorlauncher do not restore ES visibility. Root cause is environmental (CRT Script, first_script, display config, or Batocera/emulatorlauncher behavior on this setup).

**Update 2:** Mode Switcher (dialog/yad, not Pygame) also does not return to ES. **System-wide** — all ES-launched apps fail to restore ES visibility. Not Pygame, not our app. Points to first_script, emulatorlauncher resolution restore, or display/CRT config on this system.

**Update 3:** SNES exits a game and returns to ES correctly. **Not system-wide** — libretro (RetroArch) works. Failing apps: steam/sh (Add Non-Steam Games), BUA, Mode Switcher — all use emulator=sh or non-libretro. Hypothesis: emulatorlauncher resolution/video handling differs for sh vs libretro; sh path breaks ES restore.

**Update 4:** Start hotkey (pkill exit) doesn't work. Added Hotkey+Select as alternate. User must press **Hotkey+Start** or **Hotkey+Select** (hold Hotkey, tap Start or Select) — not just Start alone. If still no response, evmapy may not be injecting; SSH + `pkill -9 -f add-non-steam-game` is fallback.

**Update 5:** In-app **Select+Start** (Back+Start) now forces exit. App reads controller directly, so evmapy hotkey may never fire; handling Select+Start in Pygame ensures user can always exit. Redeploy to get this.

**Update 6:** **F4+ALT** works as escape — Batocera system combo kills current process. User confirmed this is the reliable way to exit when stuck.

**Update 7:** Switched to **HD mode Wayland** — same behavior. BUA, Add Non-Steam Games, CRT Mode Switcher all fail to return to ES. **Not CRT-specific** — happens on Wayland too. Confirms sh-based apps don't restore ES across X11 and Wayland.

**Update 8:** Killing processes doesn't restore ES. **Reboot required** every time after exiting sh-based apps.

**Update 9:** **`killall emulationstation`** works — restarts ES and restores display without reboot. User confirmed. Use via SSH when screen is black after exiting BUA, Steam games, Add Non-Steam Games, CRT Mode Switcher.
