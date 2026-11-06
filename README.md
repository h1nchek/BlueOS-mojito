# BlueOS for Xiaomi Redmi Note 10 (mojito)

This repository tracks the work required to bring BlueOS to the Xiaomi Redmi Note 10 4G (codename `mojito`, Snapdragon 678).

## Status

**Porting in progress — no flashable build is available.** Device-tree, kernel, vendor blobs, and LineageOS 24.0 compatibility still need to be verified together.

## Planned approach

1. Establish a working LineageOS 24.0 device configuration for `mojito`.
2. Verify the matching kernel source and proprietary vendor files.
3. Build and test the base ROM before integrating BlueOS.
4. Add the upstream BlueOS product configuration and build again.

## Safety

Do not flash untested images. Unlocking the bootloader or flashing firmware can erase user data. Keep a separate backup and never publish signing keys or private credentials.

## Upstream

- BlueOS: https://github.com/GDmio/BlueOS
