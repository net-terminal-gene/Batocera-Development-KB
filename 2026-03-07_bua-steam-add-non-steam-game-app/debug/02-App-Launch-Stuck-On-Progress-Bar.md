# 02 — App Launch Stuck On Progress Bar

## Symptom

Add Non-Steam Games shows the progress bar (during "Processing Games") but gets stuck — never completes, never shows "Successfully added" dialog.

## Root Cause

**Piped yad --progress blocks** — `{ for ...; do echo $pct; echo "# text"; ... done } | yad --progress` runs the loop in a subshell. When launched from ES, the pipe can block (yad not reading, or buffering) and the progress bar never advances or closes.

**results array was in subshell** — `results+=("$name")` ran in the piped subshell, so the parent's `results` stayed empty and "Successfully added" would show no game names.

## Fix Applied

Replace piped progress with **pulsate-in-background** (same pattern as scanning dialogs):

1. Start `yad --progress --pulsate` in background, capture PID
2. Run processing loop in **foreground** (main shell)
3. Kill yad when done
4. `results` now populated correctly in main shell

```bash
YAD_PID=$(yad_progress_pulsate "Processing $total game(s)...\n\nSetting up launchers...")
results=()
for entry in "${resolved_list[@]}"; do
  ...
  results+=("$name")
done
kill "$YAD_PID" 2>/dev/null || true
```

Trade-off: Progress bar pulses (no percentage) instead of showing actual progress. Avoids pipe/subshell blocking.
