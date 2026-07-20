# TWRP Build for Xiaomi 14T Pro (rothko)

Automated TWRP build for Xiaomi 14T Pro (codename: `rothko`) using GitHub Actions.

## Device Info

| Item | Value |
|------|-------|
| Device | Xiaomi 14T Pro |
| Codename | rothko |
| Model | 2407FPN8EG |
| Platform | MediaTek Dimensity 9300+ (MT6989) |
| Architecture | ARM64 |
| Android | 16 |
| TWRP Version | 14.1 |
| Partition Scheme | A/B (Virtual A/B with compression) |
| Recovery Location | Vendor Boot |

## How to Build

1. Go to **Actions** tab
2. Select **Build TWRP for Xiaomi 14T Pro (rothko)** workflow
3. Click **Run workflow**
4. (Optional) Change the TWRP manifest branch (default: `twrp-14.1`)
5. Wait for the build to complete (~2-4 hours)
6. Download the artifact from the completed workflow run

## Source Repos

| Component | Repository | Branch |
|-----------|-----------|--------|
| Device Tree | [JonesqPacMan/android_device_xiaomi_rothko_twrp](https://github.com/JonesqPacMan/android_device_xiaomi_rothko_twrp) | `twrp-14.1_a16` |
| TWRP Manifest | [minimal-manifest-twrp/platform_manifest_twrp_aosp](https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp) | `twrp-14.1` |
| Device Dump | [RandomPush/xiaomi_rothko_dump](https://github.com/RandomPush/xiaomi_rothko_dump) | `missi-user-15-AP3A.240617.008-OS2.0.11.0.VNNEUXM-release-keys` |

## Build Details

- Uses `ALLOW_MISSING_DEPENDENCIES := true` for minimal manifest compatibility
- Prebuilt DTB included in device tree (`prebuilt/dtb`)
- Generic Kernel Image (GKI) enabled
- Crypto (FBE + metadata decrypt) enabled
- Fastbootd included
- Haptic feedback support (haptic.ko)

## Flashing

After building, flash the recovery image via fastboot:

```bash
# Reboot to fastbootd
adb reboot fastboot

# Flash recovery (if applicable)
fastboot flash recovery recovery.img

# Or boot TWRP temporarily
fastboot boot recovery.img
```

## Notes

- First build may take 3-4 hours due to full source sync
- Subsequent builds use ccache and should be faster (~1-2 hours)
- Build artifacts are kept for 30 days
- The workflow uses shallow clone (`--depth=1`) to save disk space
