#!/bin/bash
# Fix libtar AIDL dependency - remove entire FBE crypto section
# Usage: setup_prebuilt_aidl.sh <device>

DEVICE="$1"
LIBTAR_MK="bootable/recovery/libtar/Android.mk"

if [ ! -f "$LIBTAR_MK" ]; then
  echo "ERROR: $LIBTAR_MK not found"
  exit 1
fi

echo "=== Original libtar/Android.mk ==="
cat "$LIBTAR_MK"
echo ""

# Strategy: Replace the entire ifeq TW_INCLUDE_CRYPTO_FBE block with just the USE_FSCRYPT flags
# This removes all problematic AIDL dependencies while keeping basic FSCRYPT support

# Use Python for reliable multi-line block replacement
python3 << 'PYEOF'
import re

with open("bootable/recovery/libtar/Android.mk", "r") as f:
    content = f.read()

# Remove the entire ifeq ($(TW_INCLUDE_CRYPTO_FBE), true) block
# Pattern: from "ifeq ($(TW_INCLUDE_CRYPTO_FBE), true)" to the matching "endif"
# We need to handle nested ifeq/endif properly

lines = content.split('\n')
result = []
skip = False
depth = 0

for line in lines:
    stripped = line.strip()

    if not skip:
        if 'ifeq ($(TW_INCLUDE_CRYPTO_FBE)' in stripped or 'ifeq ($(TW_INCLUDE_CRYPTO_FBE),' in stripped:
            skip = True
            depth = 1
            result.append('# FBE crypto dependencies removed for minimal manifest compatibility')
            result.append('# Re-enable when AIDL modules are available in the build tree')
            continue
        result.append(line)
    else:
        if stripped.startswith('ifeq') or stripped.startswith('ifdef') or stripped.startswith('ifneq'):
            depth += 1
        elif stripped == 'endif':
            depth -= 1
            if depth == 0:
                skip = False
        # Keep the USE_FSCRYPT and FSCRYPT_POLICY lines
        if 'USE_FSCRYPT' in stripped or 'FSCRYPT_POLICY' in stripped:
            result.append(line)

with open("bootable/recovery/libtar/Android.mk", "w") as f:
    f.write('\n'.join(result))

print("=== Patched libtar/Android.mk ===")
PYEOF

echo ""
echo "=== Result ==="
cat "$LIBTAR_MK"

echo ""
echo "=== Verification ==="
if grep -q "ndk_platform\|gatekeeper_aidl" "$LIBTAR_MK"; then
  echo "WARNING: Some AIDL refs remain"
  grep -n "ndk_platform\|gatekeeper_aidl" "$LIBTAR_MK"
else
  echo "OK: All AIDL refs removed"
fi
