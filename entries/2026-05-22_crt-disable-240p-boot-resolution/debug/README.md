# Debug — Disable 240p boot / ES resolution

## Verification

```bash
bash -n /userdata/system/Batocera-CRT-Script/Batocera_ALLINONE/Batocera-CRT-Script-v43.sh
```

Run the installer through monitor profile selection; confirm UI for a profile that includes 240p.

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| `bash -n` parse error | Typo in new loop or array indexing |
| User can still select 240p | Validation missing `is_disabled` check |
| Wrong index for 640x480 | `max_choice` or loop bounds off by one |
