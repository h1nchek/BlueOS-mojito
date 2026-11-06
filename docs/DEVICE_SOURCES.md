# Redmi Note 10 (mojito) source notes

These are research leads, not a verified LineageOS 24.0 device-source set. Do not treat them as build-ready or flash-ready without checking compatibility and matching revisions.

## Candidate device trees

- VoltageOS device tree: https://github.com/VoltageOS-Devices/android_device_xiaomi_mojito
- Bootleggers device tree: https://github.com/BootleggersROM-Devices/device_xiaomi_mojito

Both are older trees. Their compatibility with LineageOS 24.0 has not been established.

## Candidate kernel

- https://github.com/ximi-mojito/android_kernel_xiaomi_mojito (branch `17.0`)

The kernel must be checked against the selected device tree, required defconfig, toolchain, and Android/LineageOS target.

## Required verification

- Confirm the exact device variant and codename (`mojito`; check `sunny` references carefully).
- Find a device tree explicitly maintained or adapted for LineageOS 24.0.
- Match kernel source, defconfig, modules, and vendor blobs to the same firmware/device baseline.
- Establish a successful clean LineageOS 24.0 build and boot before adding BlueOS.
- Follow the upstream BlueOS porting and build documentation: https://github.com/GDmio/BlueOS

No proprietary blobs, signing keys, or firmware images are included in this repository.
