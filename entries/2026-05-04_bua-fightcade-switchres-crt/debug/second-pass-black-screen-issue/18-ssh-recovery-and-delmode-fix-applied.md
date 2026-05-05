# 18 — SSH recovery + `fightcade_drop_stale_switchres_modes` fix

## Mandatory bundle (recovery + deploy check)

### Post-recovery `xrandr` (head)

```text
Screen 0: minimum 320 x 200, current 641 x 480, maximum 16384 x 16384
DP-1 connected primary 641x480+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98 +
   641x480       60.00*
  SR-1_384x224@59.60 (0x3d1)  7.841MHz -HSync -VSync
```

### Deployed wrapper (`grep`)

```text
282:fightcade_drop_stale_switchres_modes() {
361:    fightcade_drop_stale_switchres_modes
```

---

**Recovery (automated):** **`batocera-resolution minTomaxResolution`**, **`xrandr --output DP-1 --mode 641x480 --rate 60`** (fallback **`641x480i` / `59.98`**), **`pkill`** **`fcadefbneo.exe`** and **`switchres_fightcade_wrap.sh`**. Raster returned to **641×480** menu timing.

**Code fix:** **`fightcade_drop_stale_switchres_modes`** in **`switchres_fightcade_wrap.template.sh`**: before **`switchres -s -k`**, delete lingering **`SR-*`** modes with **`xrandr --delmode <output> <mode>`** so the next Switchres add is not a duplicate (**`13`**, **`17`**). Deployed to **`batocera.local`** same session.

**KB:** **`VERDICT.md`**, **`plan.md`** updated.

**Retest:** Quit to ES → Fightcade → SFIII → TEST GAME with Switchres on (**no** **`fightcade-switchres.disable`**). Confirm picture + native timing.
