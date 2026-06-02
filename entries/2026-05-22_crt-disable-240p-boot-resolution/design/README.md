# Design — Disable 240p boot / ES resolution

## Architecture

After `monitor_info[]` is filled from the monitor matrix row:

1. Compute `max_choice` and parallel `is_disabled[i]` for each resolution string matching `*x240@*`.
2. If any disabled row exists, print the static callout block above the numbered list.
3. List loop: disabled entries print `   : <mode>   [DISABLED: …]` with no leading number; enabled entries keep `%2d : mode`.
4. Read loop: accept only integers in `[1,max_choice]` where `is_disabled[n]` is false.

Matrices are unchanged so Switchres and downstream tooling still see 240p in the profile line where applicable.
