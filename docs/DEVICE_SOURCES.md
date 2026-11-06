# Redmi Note 10 (mojito) — source audit

Checked on 2026-11-06. This is source-level validation only, not a successful build or boot test.

## Candidate device source set

The following repositories expose branch `17.0`:

| Build path | Repository | Verification |
|---|---|---|
| `device/xiaomi/mojito` | https://github.com/ximi-mojito/device_xiaomi_mojito | Files fetched and inspected |
| `device/xiaomi/sm6150-common` | https://github.com/ximi-mojito/device_xiaomi_sm6150-common | Branch exists; contents still need review |
| `kernel/xiaomi/mojito` | https://github.com/ximi-mojito/android_kernel_xiaomi_mojito | Branch and `arch/arm64/configs/mojito_defconfig` verified |
| `vendor/xiaomi/mojito` | https://github.com/ximi-mojito/android_vendor_xiaomi_mojito | Branch exists; contents still need review |
| `vendor/xiaomi/sm6150-common` | https://github.com/ximi-mojito/android_vendor_xiaomi_sm6150-common | Branch exists; contents still need review |

## Device-tree cross-checks

- `AndroidProducts.mk` registers `lineage_mojito.mk`.
- `lineage_mojito.mk` defines product `lineage_mojito`, device `mojito`, model `Redmi Note 10`.
- `BoardConfig.mk` sets `TARGET_KERNEL_SOURCE := kernel/xiaomi/mojito` and `TARGET_KERNEL_CONFIG := mojito_defconfig`.
- OTA assert names are `mojito,sunny`.
- The device tree inherits `device/xiaomi/sm6150-common/BoardConfigCommon.mk`.
- The product makefile inherits `vendor/xiaomi/mojito/mojito-vendor.mk` and the LineageOS common phone product.

## BlueOS compatibility

Upstream BlueOS describes itself as LineageOS 24.0 / Android 17 and documents adding `vendor/blueos` plus a product include at `vendor/extra/product.mk`. Upstream's own tested device is Pixel 6a; this does not establish that mojito builds successfully.

The device source branch is named `17.0`. It appears intended for the Android 17 generation, but exact platform compatibility, required patches, vendor blobs and firmware remain to be confirmed by a clean build.

## Local manifests

- [mojito-lineage24.xml](../manifests/mojito-lineage24.xml): five device-side repositories.
- [blueos.xml](../manifests/blueos.xml): upstream BlueOS vendor tree.

## Release blockers

1. Verify all device/common/vendor dependency declarations and proprietary blob completeness.
2. Confirm that the target LineageOS 24.0 platform branch is compatible with the five `17.0` repositories.
3. Run a clean product configuration and full build.
4. Inspect the output archive and calculate SHA-256.
5. Boot-test the exact `mojito` hardware and validate radio, Wi-Fi, Bluetooth, camera, audio, sensors, fingerprint, charging, encryption and OTA.

No release ZIP, boot image or recovery image is produced by this repository yet. No private signing keys or firmware images should be committed here.
