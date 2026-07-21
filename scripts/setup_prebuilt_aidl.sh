#!/bin/bash
# Fix libtar AIDL dependency for FBE crypto support
# Falls back to sed delete if prebuilt libs not available
# Usage: setup_prebuilt_aidl.sh <device> <prebuilt_src>

DEVICE="$1"
PREBUILT_SRC="$2"
LIBTAR_MK="bootable/recovery/libtar/Android.mk"

if [ ! -f "$LIBTAR_MK" ]; then
  echo "ERROR: $LIBTAR_MK not found"
  exit 1
fi

# Check if prebuilt libs exist
if [ -d "$PREBUILT_SRC" ] && ls "$PREBUILT_SRC"/*.so 1>/dev/null 2>&1; then
  echo "=== Found prebuilt AIDL libs at $PREBUILT_SRC ==="
  PREBUILT_DIR="device/xiaomi/$DEVICE/prebuilt_aidl"
  mkdir -p "$PREBUILT_DIR"
  cp -v "$PREBUILT_SRC"/*.so "$PREBUILT_DIR/"

  # Create Android.mk for prebuilt modules
  MK="$PREBUILT_DIR/Android.mk"
  printf 'LOCAL_PATH := $(call my-dir)\n\n' > "$MK"
  for MOD in android.security.apc-ndk_platform android.system.keystore2-V1-ndk_platform android.security.authorization-ndk_platform android.security.maintenance-ndk_platform libgatekeeper_aidl; do
    printf 'include $(CLEAR_VARS)\n' >> "$MK"
    printf "LOCAL_MODULE := $MOD\n" >> "$MK"
    printf "LOCAL_SRC_FILES := $MOD.so\n" >> "$MK"
    printf 'LOCAL_MODULE_CLASS := SHARED_LIBRARIES\n' >> "$MK"
    printf 'LOCAL_MODULE_SUFFIX := .so\n' >> "$MK"
    printf 'LOCAL_MODULE_TARGET_ARCH := arm64\n' >> "$MK"
    printf 'LOCAL_MULTILIB := 64\n' >> "$MK"
    printf 'include $(BUILD_PREBUILT)\n\n' >> "$MK"
  done

  # Add to device.mk
  printf '\n# Prebuilt AIDL libs for FBE crypto\n' >> "device/xiaomi/$DEVICE/device.mk"
  printf 'PRODUCT_PACKAGES += \\\n' >> "device/xiaomi/$DEVICE/device.mk"
  for lib in android.security.apc-ndk_platform android.system.keystore2-V1-ndk_platform android.security.authorization-ndk_platform android.security.maintenance-ndk_platform libgatekeeper_aidl; do
    printf "    $lib \\\\\n" >> "device/xiaomi/$DEVICE/device.mk"
  done

  echo "=== FBE: prebuilt AIDL modules registered ==="
else
  echo "=== Prebuilt libs not found at $PREBUILT_SRC ==="
  echo "=== Falling back to sed delete ==="
  sed -i '/android\.security\.apc-ndk_platform/d' "$LIBTAR_MK"
  sed -i '/android\.system\.keystore2-V1-ndk_platform/d' "$LIBTAR_MK"
  sed -i '/android\.security\.authorization-ndk_platform/d' "$LIBTAR_MK"
  sed -i '/android\.security\.maintenance-ndk_platform/d' "$LIBTAR_MK"
  sed -i '/libgatekeeper_aidl/d' "$LIBTAR_MK"
  echo "=== FBE: AIDL deps removed from libtar ==="
fi

echo "=== libtar/Android.mk status ==="
grep -c "ndk_platform\|gatekeeper_aidl" "$LIBTAR_MK" && echo "WARNING: some AIDL refs remain" || echo "All AIDL refs handled"
