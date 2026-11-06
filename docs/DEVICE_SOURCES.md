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
- The common and device vendor makefiles contain large generated `PRODUCT_COPY_FILES` lists under their respective `proprietary/` trees. Spot checks confirmed representative files are present in GitHub: common `gps.conf` and `libqmi_cci.so`; device `a615_zap.elf` and `com.qti.tuned.default.bin`. Binary blobs were fetched successfully in base64 mode. These checks prove only those sample paths exist; they do not prove complete coverage of every makefile reference. No root-level `proprietary-files.txt`, `extract-files.sh`, or `setup-makefiles.sh` was found at the checked paths, so a full automated inventory comparison is still unavailable.

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
2. Complete a full comparison of every `PRODUCT_COPY_FILES`/Soong prebuilt reference against the committed proprietary tree, then verify firmware compatibility.
3. Confirm all five `17.0` repositories build against LineageOS 24.0.
4. Run a clean full build and inspect the ZIP and SHA-256.
5. Boot-test the exact hardware and validate radio, Wi-Fi, Bluetooth, camera, audio, sensors, fingerprint, charging, encryption and OTA.

No release ZIP, boot image or recovery image is produced by this repository yet. Do not commit private signing keys or firmware images.


### LineageOS 24.0 / Qualcomm CAF dependency cross-check

The device and common trees do not contain `lineage.dependencies`; their external build dependencies are declared through Soong namespace imports, product makefiles, and BoardConfig references. Cross-checking those paths against the LineageOS 24.0 manifest snippet confirms that the standard source manifest supplies the relevant projects:

- `hardware/google/interfaces`, `hardware/google/pixel`, and `hardware/lineage/interfaces` are standard LineageOS projects.
- `hardware/qcom-caf/common` supplies the common CAF namespace, including the `libqti-perfd-client` subdirectory, and the common manifest linkfiles.
- `hardware/qcom-caf/sm8150/audio`, `display`, and `media` are declared against the `lineage-24.0-caf-sm8150` branches.
- `hardware/qcom-caf/wlan` is declared by the LineageOS manifest on its CAF branch.

The corresponding LineageOS repositories expose the expected `lineage-24.0` / `lineage-24.0-caf-sm8150` branches. This confirms the manifest-level project mapping, not successful compilation or compatibility of every module. The common tree's references to SM8150 audio configuration files and the SM6150 C2 manifest still need to be tested in an actual sync/build.


## VINTF XML preflight utility

A repository-side XML preflight helper is available:

```bash
python3 scripts/audit-vintf.py path/to/manifest.xml path/to/compatibility_matrix.xml
```

It verifies XML well-formedness, accepted VINTF root tags, non-empty HAL names/FQNames, and duplicate exact HAL instance declarations inside each input file. It is intentionally conservative: duplicate declarations across separate files, framework/vendor matching, target-level compatibility, service registration, and runtime behavior require the Android build tools (especially `checkvintf`) in a complete synced tree.


## Soong module source preflight

`scripts/audit-soong-deps.py` indexes named module blocks in explicitly supplied `Android.bp` files and compares literal module names referenced by common dependency properties. Example:

```bash
python3 scripts/audit-soong-deps.py --strict \
  vendor/xiaomi/mojito/Android.bp \
  vendor/xiaomi/sm6150-common/Android.bp \
  vendor/qcom/opensource/display/Android.bp
```

The default mode reports dependencies not found in the supplied file set without treating them as build failures. `--strict` returns 1 for any such unindexed dependency. Because Soong namespaces and project-wide module visibility affect resolution, an unindexed name is not necessarily missing. This script does not parse the full Blueprint language and cannot replace Soong's actual dependency graph or a successful product build.
