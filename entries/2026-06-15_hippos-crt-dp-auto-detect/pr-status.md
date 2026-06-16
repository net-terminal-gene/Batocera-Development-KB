# PR Status — HippOS CRT manual setup + pipeline

## Open PRs

| Repo | PR | Branch |
|------|-----|--------|
| hippos-linux | [hippos-linux/hippos-linux#1](https://github.com/hippos-linux/hippos-linux/pull/1) | `net-terminal-gene:feat/crt-manual-dp-setup` |
| hippos-emulationstation | [hippos-linux/hippos-emulationstation#1](https://github.com/hippos-linux/hippos-emulationstation/pull/1) | `net-terminal-gene:feat/crt-settings-ui` |

Forks: [net-terminal-gene/hippos-linux](https://github.com/net-terminal-gene/hippos-linux), [net-terminal-gene/hippos-emulationstation](https://github.com/net-terminal-gene/hippos-emulationstation)

| Phase | Status | Notes |
|-------|--------|-------|
| 1 Workaround | Validated | — |
| 2 Pipeline | **Tested on hippos.local** | Pre-X crt-setup OK; 641x480i after 2 reboots from clean CRT state |
| 3 ES UI | **Code pushed** | ES binary deploy + ES-only acceptance pending (Docker build) |
| switchres apply | **Open** | exit 139 on stock binary; rebuild doc in fork `docs/build-switchres-docker.md` |

## Test plan

[design/test-plan.md](design/test-plan.md) — `./docs/dev-sync-crt.sh hippos.local`
