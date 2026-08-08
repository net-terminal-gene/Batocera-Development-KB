# BC-250 Golden Reference (SF6 looks perfect)

Captured **2026-07-22 ~23:54 MDT** while SF6 was running. Host: `10.23.6.116`.  
Raw dump: [bc250-sf6-full-audit.out](bc250-sf6-full-audit.out).

## Host

| Field | Value |
|-------|-------|
| Batocera | 43.1 2026/05/29 |
| Kernel | 6.18.16 |
| Monitor type | ms929 |
| Boot resolution log | 640x480@60 |
| cmdline EDID | `drm.edid_firmware=DP-1:edid/ms929.bin video=DP-1:e` |
| GPU | Cyan Skillfish **BC-250** `[1002:13fe]`, amdgpu, 8 GiB VRAM |
| Vulkan | RADV, Mesa 25.3.6, `AMD BC-250 (RADV GFX1013)` |

## Batocera video keys

```
global.videooutput=DP-1
global.videomode=641x480.60.00
es.resolution=641x480.60.00082
es.customsargs=--screensize 641 480 --screenoffset 00 00
steam.videomode=854x480.60.00068
```

While SF6 was up: `currentMode=854x480.60.00`, desktop **854×480**.

## XRandR modes actually exposed (critical)

Only **three** modes on `DP-1`:

```
641x480i      60.00 +preferred
641x480       60.00
SR-1_854x480@60.00i  60.00 *current
```

Note: `batocera-resolution listModes` still lists dozens of Switchres catalog modes — SF6 does **not** see those. It sees what **xrandr** exposes.

## Window geometry (wmctrl)

```
BATOCERA EmulationStation   854×480
BATOCERA Street Fighter 6   854×480
```

## Steam / Proton stack

| Item | Value |
|------|-------|
| Steam | Flatpak `com.valvesoftware.Steam` |
| Rom | `/userdata/roms/steam/Street Fighter 6.steam` → `steam://rungameid/1364780` |
| Launch Options | **none** (`LaunchOptions` count 0) |
| Proton | **Proton - Experimental** `11.0-100` |
| Runtime | SteamLinuxRuntime_4 |
| compatdata | `.../steamapps/compatdata/1364780` |
| Game path | `.../steamapps/common/Street Fighter 6/` |
| buildid | `23395122` |
| exe MD5 | `fbd76345e90639aace9e3583c1d514ac` |

## Sole graphics config

Path:

```
/userdata/saves/flatpak/data/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Street Fighter 6/config.ini
```

No SF6/Capcom ini under Proton `AppData` / `Documents`. No second `config.ini`.

### Full `config.ini` (authoritative)

```ini
[Render]
Capability=DirectX12
[Graphics]
ShaderWarmed=TRUE
EnableUserSettings=TRUE
GlobalSettings=Custom
MaxFramerate=60
TextureQuality=HIGHEST
ShaderQuality=HIGHEST
LightingQuality=STANDARD
EffectQuality=HIGHEST
BloomQuality=HIGHEST
FGObjectNumber=HIGHEST
BHDisplayNumber=HIGH
AudienceNumber=HIGHEST
ShaderWarmingEnable=True
IgnoreUserDeviceChanged=False
ShaderWarmedVersion=2.301.0
[RenderConfig]
ImageQualityRate=1
FullScreenDisplayMode=0
WindowMode=Borderless
VSync=True
AntiAliasing=TAA
MotionBlurEnable=False
DepthOfFiledEnable=True
ShadowQuality=HIGH
MeshQuality=HIGH
SamplerQuality=Anisotropic16
AOSetting=NONE
SSRSetting=CUSTOM
SSSSSetting=CUSTOM
BloomEnable=True
UpscaleType=None
[Render/Adapter]
Description=AMD BC-250 (RADV GFX1013)
VendorId=4098
DeviceId=5118
SubSysId=0
Revision=0
[Render/Display]
DisplayName=ms929
SerialNumber=
DeviceInstanceName=\\.\DISPLAY1
DisplayModeCount=3
DisplayMode0_Width=640
DisplayMode0_Height=480
DisplayMode0_RefreshRateNumerator=60000
DisplayMode0_RefreshRateDenominator=1000
DisplayMode1_Width=641
DisplayMode1_Height=480
DisplayMode1_RefreshRateNumerator=60000
DisplayMode1_RefreshRateDenominator=1000
DisplayMode2_Width=854
DisplayMode2_Height=480
DisplayMode2_RefreshRateNumerator=60000
DisplayMode2_RefreshRateDenominator=1000
```

**Interpretation:** `FullScreenDisplayMode=0` → **640×480** render mode selection; borderless window matches desktop **854×480**.

## Runtime env highlights (StreetFighter6.exe)

- `Capability` path: DX12 + `WINEDLLOVERRIDES` includes `d3d12=n;d3d12core=n;dxgi=n` (vkd3d)
- `vkd3d-proton.cache` present in game dir
- `DXVK_ENABLE_NVAPI=1` (Steam default even on AMD)
- Nested display inside Flatpak: `DISPLAY=:99.0` (host X still `:0` at 854×480)
- Shader caches under `steamapps/shadercache/1364780` (~1.2G)

## What “perfect” does *not* require

- Image quality above 100%
- AA off
- Exclusive fullscreen
- Custom Steam launch options
- A second settings file
