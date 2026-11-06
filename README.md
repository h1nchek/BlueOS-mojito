# BlueOS for Xiaomi Redmi Note 10 (mojito)

**Status: experimental port bring-up. No flashable mojito ZIP has been built or boot-tested.**

BlueOS is a fan ROM based on LineageOS 24.0 (Android 17). Its upstream project is developed on Pixel 6a; this repository tracks the separate device bring-up for Xiaomi Redmi Note 10 4G (`mojito` / `sunny`, Snapdragon 678).

## Source baseline

The candidate device, common-device, kernel and vendor trees are pinned to branch `17.0` in [manifests/mojito-lineage24.xml](manifests/mojito-lineage24.xml). The BlueOS vendor project is pinned separately in [manifests/blueos.xml](manifests/blueos.xml).

The device tree and kernel defconfig were checked directly. The other repositories' branch names were confirmed, but a clean integrated build has not been performed. See [docs/DEVICE_SOURCES.md](docs/DEVICE_SOURCES.md).

## What is still required

1. Sync LineageOS 24.0 and the local manifests on a Linux build host.
2. Audit vendor dependencies and required firmware versions.
3. Confirm the device tree builds against the exact LineageOS 24.0 platform revision.
4. Build the plain LineageOS target first; only then integrate BlueOS and resolve any patch conflicts.
5. Produce and inspect the ZIP, record its SHA-256, then complete boot and hardware testing on a Redmi Note 10.

## Safety and release policy

Do not flash artifacts unless they are explicitly built for `mojito`, checksummed, and tested. Installing an untested ROM can erase data or leave a phone unable to boot. Keep a separate backup and never publish signing keys or private credentials.

## Upstream

- BlueOS source: https://github.com/GDmio/BlueOS
- BlueOS build guide: https://github.com/GDmio/BlueOS/blob/main/BUILDING.md
- LineageOS source: https://github.com/LineageOS/android
