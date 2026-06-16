# 01 — Defaults: manual CRT, drop auto as primary

**Files:**
- `overlays/rootfs-amd64/usr/share/hippos/hippos-defaults.conf`
- `overlays/userdata/system/hippos.conf` (template comments)

## Current

```ini
crt.enabled=auto
```

## Recommended

```ini
crt.enabled=false
```

Update `hippos.conf` template comments: remove auto as recommended path; document that DP/HDMI DAC users must enable CRT in System Settings and pick **CRT VIDEO OUTPUT**.

## Rationale

Auto cannot detect DAC or CRT-vs-HD on DisplayPort. See [../research/auto-detect-limits.md](../research/auto-detect-limits.md).

Optional: keep `auto` in code for legacy VGA-only edge cases, but **never default fresh flash to auto**.
