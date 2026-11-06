# Builder handoff — Redmi Note 10 (mojito)

This guide is for a volunteer who has agreed to help compile the port. It does not claim that the current source set is build-validated.

## Repository

- Project: https://github.com/h1nchek/BlueOS-mojito
- Branch: `main`
- Target: Xiaomi Redmi Note 10 4G, codenames `mojito` / `sunny`
- Platform baseline: LineageOS manifest branch `lineage-24.0`
- Device, kernel, and vendor source branches: `17.0`
- BlueOS source: commit pinned in `manifests/blueos.xml`

Please inspect the manifests and current documentation before syncing. The device-source audit records what was checked and what remains unresolved.

## Host requirements

Use a trusted Linux x86_64 machine with:

- at least 32 GiB RAM;
- at least 350 GiB free SSD space in the build workspace;
- Git, the Android `repo` launcher, Python 3, Java, and the standard LineageOS build dependencies.

These are project workflow gates and practical recommendations, not a guarantee that the build will succeed.

## Build sequence

Use separate clean workspaces for the two stages.

1. Clone this repository and inspect the current `main` commit.
2. Run the clean LineageOS baseline:

   ```bash
   BUILD_STAGE=lineage JOBS=8 ./scripts/build.sh "$HOME/android/mojito-lineage"
   ```

3. If the baseline completes, inspect the output and preserve its full log and resolved manifest.
4. In a separate workspace, attempt BlueOS:

   ```bash
   BUILD_STAGE=blueos JOBS=8 ./scripts/build.sh "$HOME/android/mojito-blueos"
   ```

5. Check the BlueOS patch output. Any `BlueOS: FAILED` line is a blocker; do not present the result as a BlueOS build.
6. Validate the resulting OTA ZIP with `scripts/validate_ota_zip.py` and calculate SHA-256.
7. Return the build log, resolved manifest, artifact filename, checksum, and any required source changes.

Do not use the optional `manifests/blueos-pinned.xml` fallback automatically. Follow the failure investigation in [BUILDING.md](BUILDING.md) first.

## Reporting results

For each stage, report one of:

- **Not attempted**
- **Failed** — include the failing command and relevant redacted log excerpt
- **Compiled** — full build command exited successfully; include resolved manifest and artifact checksum
- **Boot-tested** — include device model/variant, installation method, build fingerprint, and observed results

A successful compile is not a boot test. Do not flash an unverified image on a daily-use device.

## Safe collaboration

- Work through a public branch and pull request.
- Do not request or share the repository owner's password, personal access tokens, SSH private keys, signing keys, or runner registration token.
- Do not grant broad repository or organization access merely to run a build.
- A self-hosted runner executes repository code. Only register a machine controlled by a trusted operator, and do not expose secrets to untrusted pull requests.
- Keep authorship and contribution credit accurate: distinguish port integration, fixes, compilation, and device testing.
