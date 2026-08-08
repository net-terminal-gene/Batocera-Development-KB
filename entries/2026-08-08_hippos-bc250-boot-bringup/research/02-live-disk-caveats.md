# Live disk caveats (recovery config, not stock)

The BC-250 drive that reaches EmulationStation is a **recovery configuration**. Some HippOS features may be weak or missing until upstream ships a proper fix (or masks are undone carefully).

## Still expected to work

- EmulationStation / X / local play
- Local ethernet (NetworkManager)
- amdgpu on DisplayPort
- SSH (`root` / `linux`)

## May be broken or degraded

| Area | Why |
|------|-----|
| Network ROM share mount / LAN discovery | Masked `hippos-network-roms*` services/timers |
| NFS / remote filesystems at boot | Masked `remote-fs.target`, `nfs-client.target` |
| “Wait until network is online” ordering | Masked `NetworkManager-wait-online` (faster boot; rare race if something assumed net-up) |
| Auto GRUB / kernel rewrite after update | Masked `hippos-update-grub`, `hippos-select-kernel` — OTA/kernel updates may not refresh EFI GRUB the stock way |
| NVIDIA suspend helpers | Masked nvidia-* stubs (irrelevant on BC-250) |
| SSH hardness | `99-debug-init.conf` + password `linux` is looser than a hardened appliance |

## First suspects if something odd appears

1. Network ROM / NFS masks  
2. GRUB not updating after a HippOS upgrade  
3. Custom EFI `grub.cfg` (LTS default) vs stock quiet latest-only  

## Not the long-term product state

See [design/proposed-flash-boot-flow.md](../design/proposed-flash-boot-flow.md) for the intended fresh-flash UX (latest default, LTS picker, without hand-masking half the stack).
