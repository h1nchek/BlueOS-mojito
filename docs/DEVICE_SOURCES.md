# Redmi Note 10 (mojito) — source audit

Checked on 2026-11-06. Source-level validation only; no successful build or boot test has been recorded.

## Candidate device source set

All five repositories expose branch `17.0`:

| Build path | Repository | Verification |
|---|---|---|
| `device/xiaomi/mojito` | https://github.com/ximi-mojito/device_xiaomi_mojito | Product, device and board makefiles inspected |
| `device/xiaomi/sm6150-common` | https://github.com/ximi-mojito/device_xiaomi_sm6150-common | Common board and product makefiles inspected |
| `kernel/xiaomi/mojito` | https://github.com/ximi-mojito/android_kernel_xiaomi_mojito | Branch and `mojito_defconfig` verified |
| `vendor/xiaomi/mojito` | https://github.com/ximi-mojito/android_vendor_xiaomi_mojito | Device vendor makefile inspected |
| `vendor/xiaomi/sm6150-common` | https://github.com/ximi-mojito/android_vendor_xiaomi_sm6150-common | Vendor board makefile exists; blob audit remains |

## Verified makefile relationships

- `AndroidProducts.mk` registers `lineage_mojito.mk`.
- `lineage_mojito.mk` defines `lineage_mojito`, device `mojito`, model `Redmi Note 10`, and inherits LineageOS common phone configuration.
- `device.mk` inherits `device/xiaomi/sm6150-common/sm6150.mk` and `vendor/xiaomi/mojito/mojito-vendor.mk`.
- `device.mk` optionally inherits Leica camera and MIUI-app vendor configs if those directories exist.
- `BoardConfig.mk` selects `kernel/xiaomi/mojito` and `mojito_defconfig`, asserts `mojito,sunny`, and includes common and device vendor board configs.
- `BoardConfigCommon.mk` includes `vendor/xiaomi/sm6150-common/BoardConfigVendor.mk`.
- `sm6150.mk` inherits `vendor/xiaomi/sm6150-common/sm6150-common-vendor.mk` and references Qualcomm CAF common and SM8150 audio projects.
- The inspected common vendor makefile contains a substantial `PRODUCT_COPY_FILES` list under its `proprietary/` tree. File-by-file blob coverage and firmware matching have not yet been established.

## BlueOS patch integration

Upstream `vendorsetup.sh` runs `scripts/apply-patches.sh` when `build/envsetup.sh` is sourced. The patch script exits nonzero if any patch fails, so the build script's `set -e` should stop at that stage rather than silently producing a non-BlueOS build.

Upstream `manifests/blueos-pinned.xml` currently contains 12 `extend-project` entries with empty `name` values. That is not a usable project selector. This repository carries a corrected local fallback at `manifests/blueos-pinned.xml`. Its 12 revisions have now been matched to their actual LineageOS project paths by resolving the commit SHAs against the corresponding GitHub project repositories. The earlier draft had several revisions assigned to the wrong paths; the mapping has been corrected. The manifest still needs an actual `repo sync` test in a complete LineageOS checkout before it can be treated as build-validated. Use it only if fresh-branch patch application fails.

## Manifest coverage and unresolved dependencies

The local device manifest declares all five direct device, kernel and vendor repositories. The makefiles also reference platform projects expected from the LineageOS manifest and optional external vendor projects. The optional Leica/MIUI trees are guarded by `inherit-product-if-exists` and are not declared by this port manifest.

Source inspection does not prove that all proprietary files referenced by generated vendor makefiles exist, that firmware matches, or that every Qualcomm CAF project resolves to a compatible revision. A clean sync and product build are still required.

## Compatibility

Upstream BlueOS targets LineageOS 24.0 / Android 17. Its main development device is Pixel 6a; that does not establish support for mojito. Device branch `17.0` is a plausible Android 17 target, but its name alone does not prove compatibility with the exact LineageOS platform manifest. Every BlueOS patch must apply on the synced revisions.

## Local manifests

- [mojito-lineage24.xml](../manifests/mojito-lineage24.xml): five device-side repositories.
- [blueos.xml](../manifests/blueos.xml): upstream BlueOS.
- [blueos-pinned.xml](../manifests/blueos-pinned.xml): corrected fallback pins for BlueOS 0.8.1 patch projects.

## Release blockers

1. Validate the corrected fallback manifest with `repo sync` if it is needed.
2. Audit vendor blob inventories and firmware compatibility.
3. Confirm all five `17.0` repositories build against LineageOS 24.0.
4. Run a clean full build and inspect the ZIP and SHA-256.
5. Boot-test the exact hardware and validate radio, Wi-Fi, Bluetooth, camera, audio, sensors, fingerprint, charging, encryption and OTA.

No release ZIP, boot image or recovery image is produced by this repository yet. Do not commit private signing keys or firmware images.
