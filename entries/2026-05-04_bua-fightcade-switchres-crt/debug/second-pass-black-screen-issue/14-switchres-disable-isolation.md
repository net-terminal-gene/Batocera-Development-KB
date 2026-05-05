# 14 — Switchres bypass isolation (`fightcade-switchres.disable`)

**Purpose:** See whether **TEST GAME black screen** depends on **Switchres** (`-s -k` path) vs **Wine / FBNeo / windowing** alone.

**Mechanism:** Wrapper **`fightcade_should_use_switchres`** returns false when **`/userdata/system/configs/fightcade-switchres.disable`** exists (`switchres_fightcade_wrap.template.sh`). **`xdg-open`** then runs **`fcade.sh`** without Switchres.

---

## Action taken (device)

```bash
mkdir -p /userdata/system/configs
touch /userdata/system/configs/fightcade-switchres.disable
```

**Verified on `batocera.local`:**

```text
-rw------- 1 root root 0 May  4 17:42 /userdata/system/configs/fightcade-switchres.disable
```

```text
disable_active
```

---

## Mandatory bundle (SSH immediately after enable; idle)

**Note:** Raster may still reflect **prior `13` session** (**384×224**). If display is wrong or black, run **`batocera-resolution minTomaxResolution`** (and your usual **`xrandr`** menu mode) **before** the isolation retest so ES/Fightcade start from a known **641×480** menu. [Inference from **`13`** broken `xrandr` line.]

### `batocera-resolution`

```text
xorg
```

(`currentMode` / `currentResolution` empty at this capture.)

### `xrandr` (first 15 lines) + `wmctrl -l`

```text
Screen 0: minimum 320 x 200, current 384 x 224, maximum 16384 x 16384
DP-1 connected primary (normal left inverted right x axis y axis)
   641x480i      59.98 +
   641x480       60.00
  SR-1_384x224@59.60 (0x3d1)  7.841MHz -HSync -VSync
        h: width   384 start  415 end  452 total  506 skew    0 clock  15.50KHz
        v: height  224 start  234 end  237 total  260           clock  59.60Hz
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
```

**Window count:** **2**

### `/tmp/.X11-unix/`

```text
srwxrwxrwx 1 root root 0 May  4 17:27 X0
```

### Processes (`pgrep`) — note after touching disable

An **existing** **`switchres_fightcade_wrap.sh`** from **`13`** may still be running until you **exit the emulator** or **kill** it. The disable flag applies on the **next** **`fcade://`** launch only.

```text
22164 /bin/bash /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh fcade://play/fbneo/sfiii3nr1
```

### `fightcade.log` (`tail -15`)

Heartbeats only at capture.

### Wrapper sleep line (unchanged)

```text
332:    sleep 4
```

---

## Critical: make the next TEST GAME use the bypass

1. **Exit** FBNeo / wait for wrapper to finish, **or** **`pkill`** stuck wrapper/emulator if needed.
2. **Then** launch **TEST GAME** again so **`xdg-open`** invokes the wrapper **with** **`fightcade-switchres.disable`** present (plain **`fcade.sh`** branch).

If you TEST GAME while the **old** wrapped process is still alive, you have **not** tested the bypass yet.

---

## Your test procedure (must do on hardware)

1. **Optional recovery:** If stuck from **`13`**, restore menu timing, then **quit Fightcade to ES** or reboot so you begin from a **clean 641×480** ES baseline.
2. **Confirm flag:** File above must exist (already done).
3. **Repeat failing path:** Launch Fightcade → SFIII room → **TEST GAME**.
4. **Record:** Picture **or** black?
5. **SSH bundle after TEST GAME** for **`15-test-game-switchres-disabled-isolation-result.md`** (full mandatory blocks like **`13`**).
6. **Remove bypass when done testing:**

```bash
rm /userdata/system/configs/fightcade-switchres.disable
```

---

## How to read the result

| Outcome | Interpretation |
|---------|----------------|
| **Picture with disable; black with Switchres** | Strong signal to fix **Switchres / wrapper / restore / duplicate mode** path. |
| **Still black with disable** | Prioritize **Wine / FBNeo / Electron / fullscreen / WM** (not Switchres timing alone). |

---

## Related

- **`13-test-game-black-screen-bug-round-trip.md`** (black screen + odd `xrandr` / `wmctrl`).
