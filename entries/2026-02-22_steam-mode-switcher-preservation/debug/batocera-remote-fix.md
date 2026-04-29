# Fix Batocera Remote Access (HD Mode)

**Diagnosis from SSH (2026-02-22):** System is in HD Mode (Wayland + Xwayland). BUA Steam installed at `/userdata/system/add-ons/steam`. SSH works. Web UI port 1234 bound to 127.0.0.1 (localhost only). No `steam.*` lines in batocera.conf.

---

## 1. Web UI Not Reachable (batocera.local:1234)

**Cause:** Port 1234 is bound to `127.0.0.1` (localhost), not `0.0.0.0`, so it's not reachable from another machine.

**Option A — Via Batocera UI (permanent fix):**
1. On Batocera (directly): Main Menu → **SYSTEM SETTINGS** → **FRONTEND DEVELOPER OPTIONS** → **ENABLE PUBLIC WEB ACCESS**
2. Reboot Batocera.
3. Verify: `ss -tlnp | grep 1234` — should show `0.0.0.0:1234`, not `127.0.0.1:1234`.

**Option B — SSH tunnel (immediate workaround, no reboot):**
From your Mac (or any machine with SSH):
```bash
ssh -L 1234:127.0.0.1:1234 root@batocera.local
# (enter password when prompted; leave this session open)
```
Then open **http://localhost:1234** in your browser. The tunnel forwards local port 1234 to Batocera’s localhost:1234.

---

## 2. Steam Not Working in HD Mode

**Cause:** `steam.emulator=sh` and `steam.core=sh` are missing from `batocera.conf`. BUA Steam needs these for .sh launchers to run.

**Steps (via SSH):**
```bash
# SSH in
~/bin/ssh-batocera.sh batocera.local

# Add Steam config
echo "" >> /userdata/system/batocera.conf
echo "steam.emulator=sh" >> /userdata/system/batocera.conf
echo "steam.core=sh" >> /userdata/system/batocera.conf
```

**Or:** Re-run BUA Steam install from the add-ons app (if the installer writes these lines).

**Verify:**
```bash
grep steam /userdata/system/batocera.conf
# Should show:
# steam.emulator=sh
# steam.core=sh
```

---

## 3. SSH

SSH is working. If it ever fails after reflash:
```bash
ssh-keygen -R batocera.local
```
Then reconnect; accept the new host key.

---

## 4. After CRT ↔ HD Mode Switch

- Full power cycle (not warm reboot) when switching between Wayland and X11.
- If Steam stops working after switch: re-add `steam.emulator=sh` and `steam.core=sh` (or rely on Steam preservation once that's deployed).
