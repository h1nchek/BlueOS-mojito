# Redmi Note 10 (mojito) — source audit

Checked on 2026-11-06. This is source-level validation only, not a successful build or boot test.

## Candidate device source set

The following repositories expose branch `17.0`:

| Build path | Repository | Verification |
|---|---|---|
| `device/xiaomi/mojito` | https://github.com/ximi-mojito/device_xiaomi_mojito | Product, device and board makefiles fetched and inspected |
| `device/xiaomi/sm6150-common` | https://github.com/ximi-mojito/device_xiaomi_sm6150-common | Common board and product makefiles fetched and inspected |
| `kernel/xiaomi/mojito` | https://github.com/ximi-mojito/android_kernel_xiaomi_mojito | Branch and `arch/arm64/configs/mojito_defconfig` verified |
| `vendor/xiaomi/mojito` | https://github.com/ximi-mojito/android_vendor_xiaomi_mojito | Device vendor makefile fetched and inspected |
| `vendor/xiaomi/sm6150-common` | https://github.com/ximi-mojito/android_vendor_xiaomi_sm6150-common | `BoardConfigVendor.mk` exists; further content audit required |

## Verified makefile relationships

- `AndroidProducts.mk` registers `lineage_mojito.mk`.
- `lineage_mojito.mk` defines `lineage_mojito`, device `mojito`, model `Redmi Note 10`, and inherits the LineageOS common phone product.
- `device.mk` inherits `device/xiaomi/sm6150-common/sm6150.mk` and `vendor/xiaomi/mojito/mojito-vendor.mk`.
- `device.mk` also conditionally inherits optional Leica camera and MIUI-app vendor configs.
- `BoardConfig.mk` selects `kernel/xiaomi/mojito` and `mojito_defconfig`, asserts `mojito,sunny`, and includes the common board config plus device vendor board config.
- `BoardConfigCommon.mk` includes `vendor/xiaomi/sm6150-common/BoardConfigVendor.mk`.
- `sm6150.mk` inherits `vendor/xiaomi/sm6150-common/sm6150-common-vendor.mk` and references Qualcomm CAF common / SM8150 audio projects.

## Manifest coverage and unresolved dependencies

The local device manifest declares all five direct device, kernel and vendor repositories. The makefiles also reference platform projects expected from the LineageOS manifest and optional external vendor projects. Optional Leica/MIUI camera trees are guarded by `inherit-product-if-exists`; they are not currently declared by this port manifest.

The source-level inspection does **not** prove that all proprietary files referenced by generated vendor makefiles exist, that firmware matches, or that every Qualcomm CAF project resolves to a compatible revision. The full common product makefile and all vendor blob lists still need a clean sync/build audit.

## BlueOS compatibility

Upstream BlueOS identifies LineageOS 24.0 / Android 17 as its base and documents adding `vendor/blueos` plus a product include at `vendor/extra/product.mk`. Its README identifies Pixel 6a as the main development device; that does not establish support for mojito.

The device source branch is named `17.0`, which is a plausible Android 17 target, but the branch name alone is not proof of compatibility with the selected LineageOS `lineage-24.0` manifest. BlueOS also applies patches during `source build/envsetup.sh`; every patch must apply successfully on the exact synced platform revisions.

## Local manifests

- [mojito-lineage24.xml](../manifests/mojito-lineage24.xml): five device-side repositories.
- [blueos.xml](../manifests/blueos.xml): upstream BlueOS vendor tree.

## Release blockers

1. Finish auditing common device makefiles, vendor blob inventories and all project dependencies.
2. Confirm the target LineageOS 24.0 platform branch is compatible with all five `17.0` repositories.
3. Confirm every BlueOS patch applies; inspect all `BlueOS: FAILED` output.
4. Run product configuration and a clean full build on a suitable Linux host.
5. Inspect the output archive and calculate SHA-256.
6. Boot-test the exact `mojito` hardware and validate radio, Wi-Fi, Bluetooth, camera, audio, sensors, fingerprint, charging, encryption and OTA.

No release ZIP, boot image or recovery image is produced by this repository yet. No private signing keys or firmware images should be committed here.
