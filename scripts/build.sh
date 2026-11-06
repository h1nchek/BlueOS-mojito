#!/usr/bin/env bash
set -Eeuo pipefail

# Build sources only; this script does not flash a phone.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="${1:-$HOME/android/blueos-mojito}"
JOBS="${JOBS:-$(nproc)}"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "ERROR: use a Linux x86_64 build host." >&2
  exit 1
fi
if ! command -v repo >/dev/null 2>&1; then
  echo "ERROR: the Android repo tool is not installed or not in PATH." >&2
  exit 1
fi
if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "ERROR: this build setup expects an x86_64 Linux host." >&2
  exit 1
fi
mkdir -p "$ANDROID_DIR"
AVAILABLE_GB="$(df -BG "$ANDROID_DIR" | awk 'NR==2 {gsub(/G/,"",$4); print $4}')"
if [[ -z "$AVAILABLE_GB" || "$AVAILABLE_GB" -lt 350 ]]; then
  echo "ERROR: upstream recommends at least 350 GB free SSD space; found ${AVAILABLE_GB:-unknown} GB." >&2
  exit 1
fi

cd "$ANDROID_DIR"
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs --no-clone-bundle

mkdir -p .repo/local_manifests
cp "$ROOT/manifests/mojito-lineage24.xml" .repo/local_manifests/
cp "$ROOT/manifests/blueos.xml" .repo/local_manifests/

echo "Syncing LineageOS, BlueOS and mojito device sources..."
repo sync -j"$JOBS"

# Keep the SM6150 C2 vendor compatibility manifest in the device manifest list.
python3 "$ROOT/scripts/patch-mojito-device-tree.py"

mkdir -p vendor/extra
PRODUCT_INCLUDE='$(call inherit-product, vendor/blueos/config/blueos.mk)'
touch vendor/extra/product.mk
grep -qxF "$PRODUCT_INCLUDE" vendor/extra/product.mk || echo "$PRODUCT_INCLUDE" >> vendor/extra/product.mk

echo "Starting experimental BlueOS build for mojito..."
source build/envsetup.sh
breakfast mojito
m bacon -j"$JOBS"

echo
echo "Build command completed. Inspect out/target/product/mojito/, verify the ZIP and SHA-256, then arrange device testing."
