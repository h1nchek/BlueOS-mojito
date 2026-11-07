# TrebleDroid GSI source integration

This is a separate generic-system-image (GSI) source track for the BlueOS project.
It does **not** replace the existing Redmi Note 10 device-ROM build.

## Source baseline

- Android generation: Android 16
- Base manifest: LineageOS `lineage-23.2`
- Treble compatibility overlay: [TrebleDroid/treble_manifest](https://github.com/TrebleDroid/treble_manifest), ref `android-16.0`
- Treble device tree: [TrebleDroid/device_phh_treble](https://github.com/TrebleDroid/device_phh_treble), ref `android-16.0`
- Source manifest: [`manifests/trebledroid-android16.xml`](../manifests/trebledroid-android16.xml)

The manifest was transcribed from the upstream TrebleDroid Android 16 manifest. Its project revisions are intentionally kept explicit so the source overlay is reviewable.

## Why this is separate

A GSI builds a generic Android system image and uses the phone's existing vendor implementation. It is not the same artifact as a device-specific ROM ZIP. The existing `mojito` build remains based on its own LineageOS/device/vendor manifest and must not inherit this GSI overlay.

## Build status

<badge>Source manifest connected · build not yet validated</badge>

The source overlay is connected, but this repository does not yet claim a successful GSI build. Before enabling an automated build, the following must be verified against the checked-out Android 16 source tree:

1. The exact LineageOS Android 16 manifest branch and compatibility with TrebleDroid's `android-16.0` projects.
2. The current `device/phh/treble/generate.sh` invocation and generated product makefiles.
3. The exact available lunch target for the required ARM64 variant.
4. Patch application status and any conflicts after `repo sync`.
5. Successful production and validation of `system.img` on a Linux build host.

Do not guess the lunch target or silently fall back to an older phh manifest. The first build should be a manual, logged validation run; only then should it become a GitHub Actions workflow.

## Device compatibility

The generic target for the Redmi Note 10 family is expected to be ARM64, but the correct GSI variant still depends on the device's vendor/VNDK and partition configuration. Validate the exact `mojito/sunny` device properties and Treble Info requirements before selecting a final image flavor.

A successful GSI compilation does not prove that it boots or that camera, fingerprint, VoLTE, NFC, audio, encryption, and other hardware features work on the Redmi Note 10.

## Upstream references

- [TrebleDroid organization](https://github.com/TrebleDroid)
- [TrebleDroid manifest, Android 16](https://github.com/TrebleDroid/treble_manifest/blob/android-16.0/manifest.xml)
- [TrebleDroid generic device tree](https://github.com/TrebleDroid/device_phh_treble)
- [TrebleDroid build repository](https://github.com/TrebleDroid/treble_experimentations)
- [AOSP GSI documentation](https://source.android.com/docs/core/tests/vts/gsi)
