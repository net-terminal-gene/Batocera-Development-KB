# 06 — GuiMenu.cpp: expand CRT section

**File:** `src/frontend/emulationstation/es-app/src/guis/GuiMenu.cpp` (~line 1880)

**Repo:** hippos-emulationstation submodule

## Current (2 controls)

```cpp
// ── CRT monitor ──────────────────────────────────────────────────────────
s->addGroup(_("CRT MONITOR"));

auto crtEnabled = std::make_shared<SwitchComponent>(mWindow);
crtEnabled->setState(SystemConf::getInstance()->get("crt.enabled") == "true");
s->addWithDescription(_("ENABLE CRT OUTPUT"),
    _("Output 15kHz/25kHz/31kHz signal. Requires restart. AMD GPU + DVI-I or VGA recommended."),
    crtEnabled);

auto crtProfile = std::make_shared<OptionListComponent<std::string>>(mWindow, _("MONITOR PROFILE"), false);
// ... generic_15, arcade_15_25_31, etc. ...

s->addSaveFunc([s, crtEnabled, crtProfile, curProfile] {
    // sets crt.enabled, crt.monitor_profile → exitreboot
});
```

## Recommended additions

Rename group to **`CRT`** and add:

### CRT VIDEO OUTPUT → `crt.output`

Populate from script (pattern exists for resolutions):

```cpp
// ApiSystem already shells out to hippos-resolution — see ApiSystem.cpp
// executeEnumerationScript("hippos-resolution listOutputs");
auto crtOutput = std::make_shared<OptionListComponent<std::string>>(mWindow, _("CRT VIDEO OUTPUT"), false);
std::string curOutput = SystemConf::getInstance()->get("crt.output");
if (curOutput.empty()) curOutput = "auto";
crtOutput->add(_("Auto"), "auto", curOutput == "auto");
for (auto& out : ApiSystem::getInstance()->getVideoOutputDevices())  // or new getCrtOutputs()
    crtOutput->add(out, out, curOutput == out);
s->addWithDescription(_("CRT VIDEO OUTPUT"),
    _("Select the port your display or DAC is connected to (e.g. DP-1 for DP-to-VGA adapters)."),
    crtOutput);
```

Use existing `hippos-resolution listOutputs` if no C++ helper yet:

```bash
hippos-resolution listOutputs
# DP-1
# HDMI-A-1
```

### BOOT RESOLUTION → `crt.boot_resolution`

Add script command (see [07-hippos-resolution-boot-modes.md](07-hippos-resolution-boot-modes.md)):

```cpp
auto crtBootRes = std::make_shared<OptionListComponent<std::string>>(mWindow, _("BOOT RESOLUTION"), false);
std::string profile = SystemConf::getInstance()->get("crt.monitor_profile");
std::string curBoot = SystemConf::getInstance()->get("crt.boot_resolution");
// Populate from hippos-resolution listCrtBootModes --profile=<profile>
// Labels: "640x480i @ 15 kHz" → stored value "640x480i" (extend format if needed)
```

### saveFunc — reboot on any CRT boot-affecting change

```cpp
if (crtOutput->changed()) {
    SystemConf::getInstance()->set("crt.output", crtOutput->getSelected());
    s->setVariable("exitreboot", true);
}
if (crtBootRes->changed()) {
    SystemConf::getInstance()->set("crt.boot_resolution", crtBootRes->getSelected());
    s->setVariable("exitreboot", true);
}
```

### Help text fix

Replace *"DVI-I or VGA recommended"* with *"For DP/HDMI to VGA adapters, enable CRT and select that port (e.g. DP-1)."*

## ES enable switch

Only `crt.enabled == "true"` enables CRT (not `"auto"`). Matches Phase 3 manual-only UX.
