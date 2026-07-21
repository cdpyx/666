#!/bin/bash
# Setup prebuilt AIDL libraries for FBE crypto support
# Usage: setup_prebuilt_aidl.sh <device> <prebuilt_src>

DEVICE="$1"
PREBUILT_SRC="$2"
PREBUILT_DIR="device/xiaomi/$DEVICE/prebuilt_aidl"

if [ ! -d "$PREBUILT_SRC" ]; then
  echo "ERROR: Prebuilt libs not found at $PREBUILT_SRC"
  exit 1
fi

mkdir -p "$PREBUILT_DIR"
cp -v "$PREBUILT_SRC"/*.so "$PREBUILT_DIR/"

# Create Android.mk
MK="$PREBUILT_DIR/Android.mk"
echo "LOCAL_PATH := \$(call my-dir)" > "$MK"
echo "" >> "$MK"

for MOD in android.security.apc-ndk_platform android.system.keystore2-V1-ndk_platform android.security.authorization-ndk_platform android.security.maintenance-ndk_platform libgatekeeper_aidl; do
  echo "include \$(CLEAR_VARS)" >> "$MK"
  echo "LOCAL_MODULE := $MOD" >> "$MK"
  echo "LOCAL_SRC_FILES := $MOD.so" >> "$MK"
  echo "LOCAL_MODULE_CLASS := SHARED_LIBRARIES" >> "$MK"
  echo "LOCAL_MODULE_SUFFIX := .so" >> "$MK"
  echo "LOCAL_MODULE_TARGET_ARCH := arm64" >> "$MK"
  echo "LOCAL_MULTILIB := 64" >> "$MK"
  echo "include \$(BUILD_PREBUILT)" >> "$MK"
  echo "" >> "$MK"
done

# Add to device.mk
echo "" >> "device/xiaomi/$DEVICE/device.mk"
echo "# Prebuilt AIDL libs for FBE crypto" >> "device/xiaomi/$DEVICE/device.mk"
echo "PRODUCT_PACKAGES += \\" >> "device/xiaomi/$DEVICE/device.mk"
for lib in android.security.apc-ndk_platform android.system.keystore2-V1-ndk_platform android.security.authorization-ndk_platform android.security.maintenance-ndk_platform libgatekeeper_aidl; do
  echo "    $lib \\" >> "device/xiaomi/$DEVICE/device.mk"
done

echo "=== Created $MK ==="
cat "$MK"
echo "=== device.mk tail ==="
tail -10 "device/xiaomi/$DEVICE/device.mk"
