#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="${1:-$HOME/android/blueos-mojito}"
# Default to one full BlueOS build; use lineage only as an optional diagnostic.
BUILD_STAGE="${BUILD_STAGE:-blueos}"
case "$BUILD_STAGE" in lineage|blueos) ;; *) echo "ERROR: BUILD_STAGE must be lineage or blueos; got: $BUILD_STAGE" >&2; exit 1 ;; esac
DEFAULT_JOBS="$(nproc)"
if (( DEFAULT_JOBS > 8 )); then DEFAULT_JOBS=8; fi
JOBS="${JOBS:-$DEFAULT_JOBS}"
if [[ ! "$JOBS" =~ ^[1-9][0-9]*$ ]] || (( JOBS > 8 )); then
  echo "ERROR: JOBS must be an integer from 1 to 8; got: $JOBS" >&2
  exit 1
fi
if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo "ERROR: use a Linux x86_64 build host." >&2
  exit 1
fi
command -v repo >/dev/null 2>&1 || { echo "ERROR: Android repo tool is not installed or not in PATH." >&2; exit 1; }
mkdir -p "$ANDROID_DIR"
AVAILABLE_GB="$(df -BG "$ANDROID_DIR" | awk 'NR==2 {gsub(/G/,"",$4); print $4}')"
if [[ -z "$AVAILABLE_GB" || "$AVAILABLE_GB" -lt 350 ]]; then
  echo "ERROR: at least 350 GB free SSD space is recommended; found ${AVAILABLE_GB:-unknown} GB." >&2
  exit 1
fi
cd "$ANDROID_DIR"
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs --no-clone-bundle
mkdir -p .repo/local_manifests
cp "$ROOT/manifests/mojito-lineage24.xml" .repo/local_manifests/
if [[ "$BUILD_STAGE" == blueos ]]; then
  cp "$ROOT/manifests/blueos.xml" .repo/local_manifests/
else
  rm -f .repo/local_manifests/blueos.xml
fi
echo "Syncing sources (stage: $BUILD_STAGE)..."
repo sync -j"$JOBS" --fail-fast
python3 "$ROOT/scripts/patch-mojito-device-tree.py"
PRODUCT_INCLUDE='$(call inherit-product, vendor/blueos/config/blueos.mk)'
if [[ "$BUILD_STAGE" == blueos ]]; then
  mkdir -p vendor/extra
  touch vendor/extra/product.mk
  grep -qxF "$PRODUCT_INCLUDE" vendor/extra/product.mk || echo "$PRODUCT_INCLUDE" >> vendor/extra/product.mk
  echo "Starting experimental BlueOS build for mojito..."
else
  if [[ -e vendor/blueos ]] || { [[ -f vendor/extra/product.mk ]] && grep -qxF "$PRODUCT_INCLUDE" vendor/extra/product.mk; }; then
    echo "ERROR: this source directory contains stale BlueOS files. Use a fresh, separate directory for BUILD_STAGE=lineage." >&2
    exit 1
  fi
  echo "Starting clean LineageOS baseline build for mojito (BlueOS excluded)..."
fi
repo manifest -r -o "$ROOT/resolved-manifest-$BUILD_STAGE.xml"
source build/envsetup.sh
breakfast mojito
m bacon -j"$JOBS"
echo
echo "$BUILD_STAGE build completed. Inspect the product output, verify ZIP and SHA-256, then arrange device testing."
