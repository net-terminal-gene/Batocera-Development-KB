# Research — Disable 240p boot / ES resolution

## Findings

- Matrix A (AMD / NVIDIA proprietary / Intel DP): first token often `320x240@60`.
- Matrix B (Intel non-DP / Nouveau): first token often `1280x240@60`.
- Regex `^[0-9]+x240@` matches both without touching interlaced modes like `*480i` or other heights.
