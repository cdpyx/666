#!/bin/bash
# Setup prebuilt AIDL libraries for FBE crypto support
# Falls back to sed delete if prebuilt libs not available
# Usage: setup_prebuilt_aidl.sh <device> <prebuilt_src>

DEVICE="$1"
PREBUILT_SRC="$2"
PREBUILT_DIR="device/xiaomi/$DEVICE/prebuilt_aidl"
LIBTAR_MK="bootable/recovery/libtar/Android.mk"

if [ ! -f "$LIBTAR_MK" ]; then
  echo "ERROR: $LIBTAR_MK not found"
  exit 1
fi

if [ -d "$PREBUILT_SRC" ] && [ "$(ls -A "$PREBUILT_SRC"/*.so 2>/dev/null)" ]; then
  echo "=== Found prebuilt AIDL libs at $PREBUILT_SRC ==="
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
  echo "=== FBE: prebuilt AIDL modules registered ==="
else
  echo "=== Prebuilt libs not found, using sed fallback ==="
  sed -i '/android\.security\.apc-ndk_platform/d' "$LIBTAR_MK"
  sed -i '/android\.system\.keystore2-V1-ndk_platform/d' "$LIBTAR_MK"
  sed -i '/android\.security\.authorization-ndk_platform/d' "$LIBTAR_MK"
  sed -i '/android\.security\.maintenance-ndk_platform/d' "$LIBTAR_MK"
  sed -i '/libgatekeeper_aidl/d' "$LIBTAR_MK"
  echo "=== FBE: AIDL deps removed from libtar (limited FBE support) ==="
fi

echo "=== libtar/Android.mk status ==="
grep -c "ndk_platform\|gatekeeper_aidl" "$LIBTAR_MK" && echo "WARNING: some AIDL refs remain" || echo "All AIDL refs handled"
