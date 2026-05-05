# Controller vibration tied to game audio (Fightcade / CRT session)

**Observed (hardware):** Gamepad **rumble tracks game audio** (described as vibrating “the sound”), **not** normal speaker output through TV/speakers. **Unplugging and replugging** the controller restores sane behavior.

**First recorded:** **`04-test-game-fullscreen-timing-and-controller-vibration.md`** (same investigation).

---

## Why this can happen [Inference]

Nothing below is proven against your exact pad firmware and Batocera build; these are **common mechanisms** when rumble and audio feel coupled on Linux + Wine + SDL:

### 1. Wine / SDL stack routing hidraw or evdev oddly

Wine talks to game controllers through the Linux input stack. If SDL or the Wine hid layer binds **both** force-feedback (rumble) and **PCM/audio-like timing** to the same logical device, firmware quirks or driver stacking can make motors pulse when the game pushes sound.

### 2. Steam Input / wrapper middleware [Inference]

If any wrapper normalizes “effects” into one pipe, **mis-mapping** can send bass-heavy audio envelopes to the rumble motor API instead of (or in addition to) speakers.

### 3. USB power / grounding [Inference]

Weak USB power or noisy ground can modulate motor drivers when **DAC activity** swings current on the same bus. That feels like “sound in the controller.” **Unplug/replug** changing which port or hub path often fits this pattern.

### 4. FBNeo / Fightcade / Fightcade-in-Wine only [Inference]

If it happens mainly in **Fightcade + FBNeo** and not in standalone RetroArch, blame tends toward **this Wine + emulator path**, not the CRT or Switchres raster itself. Switchres changes **video timing**, not USB audio routing; correlation may be **session coincidence**, not causation.

---

## What we **cannot** claim without more data

- Exact subsystem (`hid`, `snd`, Wine **xinput**, SDL **hint**) responsible on **your** rig.

---

## Practical workaround (confirmed by you)

1. **Unplug** USB controller.  
2. **Replug** after a few seconds (same port is OK unless hub is suspect).

If it returns often: try **another USB port**, **direct to PC** (not through the same hub as audio DAC), or test **another pad** to separate firmware bug vs wiring.

---

## If you want a real root cause later

Capture **while reproducing**:

```bash
evtest   # which device, FF events
```

Wine logs with **`WINEDEBUG=+hid,+input`** (noisy), Batocera **`/userdata/system/logs/`** around the session.

---

## Related

- **`debug/second-pass-black-screen-issue/04-test-game-fullscreen-timing-and-controller-vibration.md`**
