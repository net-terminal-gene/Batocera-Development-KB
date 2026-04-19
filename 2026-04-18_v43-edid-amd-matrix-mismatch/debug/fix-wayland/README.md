# Fix-wayland debug logs (Wayland + X11 CRT path)

**Started:** 2026-04-19  
**Session:** [v43 EDID / matrix KB](../README.md) (same investigation tree; **Wayland** lab track).  
**Related PR context:** PR #395 style **Wayland (HD) / X11 (CRT)** dual stack, not the **X11-only** `debug/fix/` ladder.

## Prerequisite (read before step 01+)

**Install the CRT Script X11 side (dual-boot or bundled X11 CRT stack) before other test steps in this directory.**

On a factory **Wayland** Batocera image you do not yet have **`xorg`**, **`DISPLAY=:0`**, **`xrandr`**, or CRT mode switcher behavior that assumes X11. Steps **01** onward assume that install has been completed (or is the subject of **01** itself). Do not mix **HDMI desktop checks** that require CRT tooling until X11 is present.

## Workflow

Same idea as [../fix/README.md](../fix/README.md): **one numbered `NN-slug.md` per checkpoint** after you finish that step on hardware. No bulk placeholder ladder.

## Filename pattern

- Two-digit **`NN`**, hyphen, short kebab slug, **`.md`**
- Body: **Date**, **Host**, **Compositor / session** (e.g. **labwc**, **Wayland**), **Purpose**, **Commands run**, **Captured output**, **Notes**

## Suggested captures (Wayland HD session)

1. `batocera-version`  
2. `echo $XDG_SESSION_TYPE` or equivalent / **process** check (**labwc**, **sway**, etc.)  
3. `batocera-resolution listOutputs` (or documented v43 Wayland equivalent)  
4. **`/userdata/system/batocera.conf`** **`global.videooutput`** / **`global.videomode`**  
5. **`/proc/cmdline`** and **`grep APPEND`** on **`/boot/EFI/syslinux.cfg`** (and **`/boot/boot/syslinux.cfg`**) to see which kernel entry is default  
6. After X11 exists: note which **syslinux DEFAULT** points at **CRT vs HD** before switching

## Index

| File | Summary |
|------|---------|
| [00-v43-wayland-first-boot.md](00-v43-wayland-first-boot.md) | Wayland-only baseline before CRT/X11 install (Mikey captured). |
| [01-crt-x11-install-from-wayland-hd.md](01-crt-x11-install-from-wayland-hd.md) | CRT Script / X11 install from **HD Wayland** session (**prerequisite** for later steps). |
| [02-crt-script-install-pre-reboot.md](02-crt-script-install-pre-reboot.md) | **X11 CRT** boot: **Phase 2** script run, captures **before** installer **reboot**. |
| [03-crt-mode-pre-mode-switcher.md](03-crt-mode-pre-mode-switcher.md) | Post-install **CRT** on **X11** (**/crt** boot), **before** **HD↔CRT** switcher round trip. |
| [04-mode-switcher-crt-to-hd-pre-reboot.md](04-mode-switcher-crt-to-hd-pre-reboot.md) | **CRT→HD (Wayland)** via switcher, **pre-reboot** (persisted config vs live **X11** **CRT**). |
| [05-hd-mode-pre-mode-switcher.md](05-hd-mode-pre-mode-switcher.md) | **Wayland HD** post-reboot baseline, **before** switcher back to **CRT**. |
| [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md) | **HD→CRT** via switcher, **pre-reboot** (saved **CRT** vs live **Wayland HD**). |
| [07-crt-mode-pre-mode-switcher.md](07-crt-mode-pre-mode-switcher.md) | **CRT** again after **HD** round trip, **before** next switcher (compare to **03**). |
| [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md) | **Second** **CRT→HD (Wayland)** pre-reboot (vs first pass **04**). |
| [09-hd-mode-pre-mode-switcher.md](09-hd-mode-pre-mode-switcher.md) | **Second** **Wayland HD** post-reboot baseline (vs **05**), **before** next switcher. |

(Add rows as you add **`10`**, **`11`**, …)
