# Redmi Note 10 (mojito) — source audit

## Finding

A substantially better source set exists than the older Android 11–15 trees listed in the initial notes: the `ximi-mojito` GitHub organization publishes a coordinated set of device, common-device, kernel, and vendor repositories on branch `17.0`. This is the strongest candidate for the BlueOS / LineageOS 24.0 target.

The source set is **not yet build- or boot-verified by this project**. Branch names and matching configuration are good evidence of intended alignment, not proof that a clean build succeeds or that the resulting image is safe to use.

## Primary candidate source set

All repositories below are under https://github.com/ximi-mojito and currently expose branch `17.0`.

| Build path | Repository |
|---|---|
| `device/xiaomi/mojito` | https://github.com/ximi-mojito/device_xiaomi_mojito |
| `device/xiaomi/sm6150-common` | https://github.com/ximi-mojito/device_xiaomi_sm6150-common |
| `kernel/xiaomi/mojito` | https://github.com/ximi-mojito/android_kernel_xiaomi_mojito |
| `vendor/xiaomi/mojito` | https://github.com/ximi-mojito/android_vendor_xiaomi_mojito |
| `vendor/xiaomi/sm6150-common` | https://github.com/ximi-mojito/android_vendor_xiaomi_sm6150-common |

### Configuration cross-checks

- The device tree identifies the product as `lineage_mojito`, model Redmi Note 10, and accepts `mojito,sunny` as OTA assert names.
- Its `BoardConfig.mk` sets `TARGET_KERNEL_SOURCE := kernel/xiaomi/mojito` and `TARGET_KERNEL_CONFIG := mojito_defconfig`.
- The kernel repository's recursive Git tree contains `arch/arm64/configs/mojito_defconfig`.
- The device tree inherits `device/xiaomi/sm6150-common` and the device/common vendor makefiles, matching the other repositories in the set.
- The device tree and kernel branches show commits by their maintainers in October 2026; the device vendor tree shows updates in February 2026. The common device tree also has October 2026 updates.

## Local manifest

Use [manifests/mojito-lineage24.xml](../manifests/mojito-lineage24.xml) as the source-set reference. It pins the five device-side repositories to branch `17.0`. The upstream BlueOS vendor manifest remains separate in [manifests/blueos.xml](../manifests/blueos.xml).

## Other trees found

- https://github.com/ProjectEverest-Devices/android_device_xiaomi_mojito — branch `15`, with a matching `sm6150-common` branch. Useful as an older Android 15 reference, but not the preferred Android 17 / LineageOS 24.0 base.
- https://github.com/crdroidandroid/android_device_xiaomi_mojito — branch `15.0`; older Android 15 base.
- https://github.com/xiaomi-sdm678/android_device_xiaomi_mojito — LineageOS 21 branch; older base.
- https://github.com/VoltageOS-Devices/android_device_xiaomi_mojito — older device tree.

## Manifest caveat

The `lineage-24.0/mojito.sh` helper in the separate `ximi-mojito/mojito_manifests` repository refers to `ximi-mojito-test` clone URLs and has the kernel clone commented out. Do not copy that helper verbatim. The source references here instead point to the public `ximi-mojito` repositories and explicitly include the kernel.

That helper's patch collection also includes a permissive SELinux policy patch. It is deliberately not included in this project's manifest; security policy changes need individual review and should not be applied merely to make a build pass.

## Remaining validation

- Confirm the full set of branch revisions and any external dependencies used by the target LineageOS 24.0 manifest.
- Review build configuration and patch requirements against the current LineageOS 24.0 source.
- Complete a clean build and maintainers' checks before considering any device testing.
- Do not treat any build as ready to flash until it has been independently tested on the exact device variant.

No signing keys, private credentials, or firmware images belong in this repository.
