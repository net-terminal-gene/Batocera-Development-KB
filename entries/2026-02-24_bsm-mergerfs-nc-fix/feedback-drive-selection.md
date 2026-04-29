# Feedback: Drive Selection (Not Just Force-to-External)

## Concern

The current `=NC` fix forces **all** new ROM writes to external drives. There is no way for the user to choose which drive they want to install things to.

That's not ideal. Users may want to:
- Put some games on the NVMe (portability, speed)
- Put others on a specific external drive
- Have control over where their content lives

## Implication

We may need to revisit the `=NC` approach. A blanket "NVMe = no create, everything goes external" solves the duplication bug but removes user choice. A better solution might involve:
- Per-system or per-write drive selection
- UI or config to let users pick the target drive for installs
- Or a different mergerFS policy that allows selective targeting

This feedback should inform any batocera.linux PR — the fix shouldn't just swap one limitation for another.
