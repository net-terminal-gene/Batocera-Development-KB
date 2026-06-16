# PR Status — HippOS CRT manual setup + pipeline

## In progress — Mikey (net-terminal-gene forks)

| Fork | Branch |
|------|--------|
| [net-terminal-gene/hippos-linux](https://github.com/net-terminal-gene/hippos-linux) | `feat/crt-manual-dp-setup` |
| [net-terminal-gene/hippos-emulationstation](https://github.com/net-terminal-gene/hippos-emulationstation) | `feat/crt-settings-ui` |

Upstream targets: [hippos-linux/hippos-linux](https://github.com/hippos-linux/hippos-linux), [hippos-emulationstation](https://github.com/hippos-linux/hippos-emulationstation)

| Phase | Status | Repo |
|-------|--------|------|
| 1 Workaround | Validated on hardware | — |
| 2 Pipeline fixes | Implemented, hardware test pending | hippos-linux |
| 3 ES CRT settings UI | Implemented, hardware test pending | hippos-emulationstation + hippos-linux |

PR links added after push and upstream PR creation.

## Test plan

See [design/test-plan.md](design/test-plan.md) and [docs/dev-sync-crt.sh](https://github.com/net-terminal-gene/hippos-linux/blob/feat/crt-manual-dp-setup/docs/dev-sync-crt.sh) in fork.
