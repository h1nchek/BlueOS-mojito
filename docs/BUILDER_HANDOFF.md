# One-time builder handoff — Redmi Note 10 (mojito)

This is a request for **one full BlueOS build**, not recurring build support. The source set is statically reviewed but has not yet completed a full compile or boot test.

## Repository

- Project: https://github.com/h1nchek/BlueOS-mojito
- Branch: `main`
- Target: Xiaomi Redmi Note 10 4G, codenames `mojito` / `sunny`
- Platform: LineageOS 24.0 / Android 17
- Device, kernel, and vendor source branches: `17.0`
- BlueOS source: commit pinned in `manifests/blueos.xml`

## Host requirements

Use a trusted Linux x86_64 machine with:

- at least 32 GiB RAM;
- at least 350 GiB free SSD space in the build workspace;
- Git, Android `repo`, Python 3, Java, and standard LineageOS build dependencies.

These are practical project requirements, not a guarantee that compilation will succeed.

## One-time build

1. Clone this repository and inspect the current `main` commit.
2. Run the default one-pass BlueOS build in a clean workspace:

   ```bash
   set -o pipefail
   JOBS=8 ./scripts/build.sh "$HOME/android/mojito-blueos" 2>&1 | tee "$HOME/android/mojito-blueos-build.log"
   ```

   The default stage is `blueos`. It syncs LineageOS 24.0, the five pinned device/kernel/vendor repositories, and the pinned BlueOS source, then applies the device-tree fix and BlueOS product integration before building.

3. Check the complete log. It must contain successful BlueOS patch application messages and no `BlueOS: FAILED` lines.
4. Locate the generated ROM ZIP under `out/target/product/mojito`, validate its archive structure, and calculate SHA-256.
5. Return the ROM ZIP, checksum, complete build log, and `resolved-manifest-blueos.xml`.

If the BlueOS build fails and a diagnosis is useful, a separate clean LineageOS build is available with `BUILD_STAGE=lineage`. That is an optional second compile, not part of the one-time request.

## Reporting

Report one of:

- **Not attempted**
- **Failed** — include the failing command and a relevant redacted log excerpt
- **Compiled** — full build command exited successfully; include resolved manifest and artifact checksum
- **Boot-tested** — include exact device variant, installation method, build fingerprint, and observed results

A successful compile is not a boot test. Do not present an untested artifact as a working release.

## Safe collaboration

- No recurring commitment is requested.
- Do not request or share passwords, personal access tokens, SSH private keys, signing keys, or runner registration tokens.
- Do not grant broad repository or organization access merely to run a build.
- A self-hosted runner executes repository code. Only register a machine controlled by a trusted operator, and do not expose secrets to untrusted pull requests.
- Keep credit accurate: distinguish port integration, build assistance, fixes, and device testing.
