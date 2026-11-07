<div align="center">

# BlueOS for Xiaomi Redmi Note 10

**mojito / sunny · Snapdragon 678 · Android 17 target**

[![Port status](https://img.shields.io/badge/port-experimental-orange)](#current-status--текущий-статус)
[![Base](https://img.shields.io/badge/base-LineageOS%2024.0-blue)](https://github.com/LineageOS/android)
[![Device](https://img.shields.io/badge/device-Redmi%20Note%2010-2ea44f)](#device--устройство)

*An independent device bring-up effort for BlueOS.*

</div>

> **RU:** Это независимый порт BlueOS для Xiaomi Redmi Note 10 4G. Основная подготовительная работа с исходниками, манифестами, интеграцией и инструментами проверки выполнена. Проект подготовлен к первой полноценной сборке; готовой прошивки для установки пока нет.
>
> **EN:** This is an independent BlueOS porting effort for the Xiaomi Redmi Note 10 4G. The source mapping, manifests, integration glue, and preflight tooling are prepared for the first full build. No installable ROM build is available yet.

---

## Визуальная схема / Port architecture

![BlueOS mojito source architecture](docs/images/port-architecture.svg)

*Схема архитектуры исходников, а не скриншот работающего телефона. / Source architecture diagram, not a screenshot of a running phone.*

## Текущий статус / Current status

![Bilingual engineering progress](docs/images/port-progress.svg)

| Направление / Area | Статус / Status |
|---|---|
| Device, common, kernel and vendor source mapping | Reviewed and pinned / Проверено и закреплено |
| LineageOS 24.0 + Qualcomm CAF dependency mapping | Reviewed / Изучено |
| SM6150 Codec2 vendor manifest ordering | Automatic guarded fix in build script / Автоматическое адресное исправление при сборке |
| Proprietary vendor source files | 455/455 referenced paths found in reviewed vendor repositories; re-audit after sync / 455/455 путей найдены в проверенных vendor-репозиториях; повторная проверка после sync |
| Soong source preflight | Tool added; target-tree scan not run / Инструмент добавлен, проверка дерева не запускалась |
| GitHub Actions preflight | Latest main run #36 passed: Python compilation, shell syntax, XML manifests and unit tests / Последний запуск main #36 успешен: Python, shell, XML и unit-тесты |
| Full GitHub Actions ROM build | Waiting for a provisioned Linux build host / Ожидает подготовленного Linux-сервера для сборки |
| ABI validation | Not run / Не выполнялась |
| Full ROM build | Pending first builder run / Ожидает первой сборки |
| Boot and hardware tests | Pending a successful build and device testing / После успешной сборки и проверки на устройстве |
| Flashable ZIP | Pending build / Появится после сборки |

**Важно / Important:** подготовка исходников и успешные preflight-проверки ещё не подтверждают успешную компиляцию или загрузку. Совместимость камеры, дисплея, связи, Wi-Fi, отпечатка, аудио и остальных компонентов будет подтверждаться только после тестирования на реальном устройстве.

---

## Что нового в репозитории / New engineering utility

### Vendor blob source auditor

A small Python utility was added to check whether the proprietary source paths referenced by the two Xiaomi vendor makefiles actually exist in a synced Android checkout. This turns the current manual blob inventory into a repeatable check.

```bash
python3 scripts/audit-vendor-blobs.py ~/android/blueos-mojito
```

You can also pass custom makefiles:

```bash
python3 scripts/audit-vendor-blobs.py ~/android/blueos-mojito \
  --makefile vendor/xiaomi/mojito/mojito-vendor.mk \
  --makefile vendor/xiaomi/sm6150-common/sm6150-common-vendor.mk
```

Exit codes: `0` = all parsed source paths exist and none are unresolved, `1` = one or more concrete source paths are missing, `2` = the audit is incomplete or could not run (for example, a makefile is missing, no entries were parsed, or a source path contains an unresolved variable).

**Scope limitation:** this checks source-file presence for concrete `PRODUCT_COPY_FILES` entries only. It does not validate ELF dependencies, Android ABI compatibility, firmware versions, licenses, VINTF compatibility, or runtime behavior.

---

### VINTF XML preflight

The new `scripts/audit-vintf.py` performs a conservative structural check on supplied Android VINTF XML files:

```bash
python3 scripts/audit-vintf.py \
  device/xiaomi/sm6150-common/configs/manifests/manifest.xml \
  hardware/qcom-caf/sm8150/media/conf_files/sm6150/c2_manifest_vendor.xml
```

It checks XML parsing, expected VINTF root elements, HAL entries without names, empty FQName values, and duplicate HAL instance declarations within each file. It does **not** resolve cross-file overrides, validate compatibility matrices, check service availability, or replace Android's `checkvintf` tool.

### Android repo manifest preflight

Run `python3 scripts/audit_repo_manifests.py manifests/*.xml` to check local manifest XML for duplicate project paths, missing project revisions, undeclared remotes, and malformed `extend-project` entries. This is a structural check only; it does not prove that remote repositories or pinned revisions exist, and `repo sync` remains authoritative.

### Soong module dependency preflight

A source-level Soong indexer is available as `scripts/audit-soong-deps.py`. Pass the `Android.bp` files you want to compare:

```bash
python3 scripts/audit-soong-deps.py --strict \
  device/xiaomi/sm6150-common/Android.bp \
  vendor/xiaomi/mojito/Android.bp \
  vendor/xiaomi/sm6150-common/Android.bp \
  hardware/qcom-caf/sm8150/display/Android.bp \
  vendor/qcom/opensource/display/Android.bp
```

It indexes named module blocks and compares literal entries in `defaults`, `shared_libs`, `static_libs`, `whole_static_libs`, `header_libs`, `runtime_libs`, `jni_libs`, `uses_libs`, `optional_uses_libs`, and `required`. Without `--strict`, names absent from the supplied files are reported as unindexed but do not fail the command; with `--strict`, they return status 1.

**Important:** Soong dependencies can be valid in other files, namespaces, or external projects. This lightweight text scan does not evaluate Blueprint expressions, defaults, visibility, architecture variants, ABI compatibility, or the final Soong graph. Treat unindexed names as follow-up leads, not confirmed build errors. A real synced build and Soong analysis remain authoritative.

## Устройство / Device

| Property | Value |
|---|---|
| Device | Xiaomi Redmi Note 10 4G |
| Codenames | `mojito` / `sunny` |
| SoC | Qualcomm Snapdragon 678 |
| CPU architecture | 64-bit ARM |
| Target platform | LineageOS 24.0 / Android 17 |
| Kernel source | Xiaomi mojito tree, branch `17.0` |
| Kernel baseline observed | Linux 4.14.357-openela |

## Исходники / Source baseline

Candidate device, common-device, kernel, and vendor repositories are pinned to branch `17.0` in [the LineageOS device manifest](manifests/mojito-lineage24.xml). BlueOS is pinned separately in [the BlueOS manifest](manifests/blueos.xml).

- Device tree: [ximi-mojito/device_xiaomi_mojito](https://github.com/ximi-mojito/device_xiaomi_mojito)
- SM6150 common tree: [ximi-mojito/device_xiaomi_sm6150-common](https://github.com/ximi-mojito/device_xiaomi_sm6150-common)
- Kernel: [ximi-mojito/android_kernel_xiaomi_mojito](https://github.com/ximi-mojito/android_kernel_xiaomi_mojito)
- Device vendor: [ximi-mojito/android_vendor_xiaomi_mojito](https://github.com/ximi-mojito/android_vendor_xiaomi_mojito)
- Common vendor: [ximi-mojito/android_vendor_xiaomi_sm6150-common](https://github.com/ximi-mojito/android_vendor_xiaomi_sm6150-common)

See [docs/DEVICE_SOURCES.md](docs/DEVICE_SOURCES.md) for the source and compatibility audit, known kernel risks, vendor HAL inventory, and build notes.

## План работ / Roadmap

1. Run one full integrated BlueOS build for `mojito` directly from the pinned sources; the clean LineageOS mode is optional diagnostics only.
2. Resolve any BlueOS patch-application or compilation errors found in that first run; preserve the complete log and resolved manifest.
3. Repeat the vendor source-path audit after `repo sync`; investigate checksums, ELF dependencies, firmware compatibility, ABI, Soong dependencies, and VINTF where applicable.
4. Inspect boot/vendor_boot/DTB/DTBO packaging and validate the resulting ZIP structure and SHA-256 checksum.
5. Arrange a separate device test on a physical Redmi Note 10; publish only verified results, known issues, logs, and checksums.

## Сборка / Build

The repository contains a build wrapper at [scripts/build.sh](scripts/build.sh) with two selectable modes: a one-pass BlueOS build (default) and a clean LineageOS diagnostic build. The latest GitHub Actions preflight on `main` (run #36) completed successfully, including Python compilation, shell syntax, XML manifest validation, and unit tests. This is a static/preflight check, **not** a full Android ROM build.

The manual [GitHub Actions build workflow](.github/workflows/build-blueos-mojito.yml) defaults to the one-pass BlueOS build and requires a provisioned self-hosted runner: x86_64 Linux, the Android `repo` tool, at least 32 GB RAM, and 350 GB of free SSD space. The first full build is the next project milestone. See [docs/BUILDING.md](docs/BUILDING.md) for the build procedure and [docs/BUILDER_HANDOFF.md](docs/BUILDER_HANDOFF.md) for a concise handoff to a volunteer builder. Contribution and safety guidance is in [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md).

## Безопасность / Safety

Do not flash images or ZIPs unless they are explicitly built for `mojito`, verified with checksums, and tested. An incompatible image can erase data or make the phone unable to boot. Keep a separate backup. Never publish signing keys, passwords, or private credentials.

## Лицензия / Licensing

The original scripts, documentation, diagrams, and project glue authored in this repository are licensed under [Apache-2.0](LICENSE), unless a file states otherwise.

**Third-party components are not relicensed by this notice.** LineageOS/Android, Linux kernel sources, Qualcomm components, device trees, and vendor repositories retain their own applicable licenses and notices. Proprietary Xiaomi/vendor blobs may have separate redistribution restrictions; this repository license does not grant permission to redistribute them.

**RU:** Оригинальные скрипты, документация, схемы и вспомогательные файлы этого репозитория распространяются по Apache-2.0, если в конкретном файле не указано иное. Лицензия не меняет условия для сторонних компонентов: Android/LineageOS, ядра Linux, Qualcomm, device tree и vendor-репозиториев. Проприетарные файлы Xiaomi могут иметь отдельные ограничения на распространение; Apache-2.0 не предоставляет прав на их распространение.

## Links

- BlueOS upstream: https://github.com/GDmio/BlueOS
- BlueOS build guide: https://github.com/GDmio/BlueOS/blob/main/BUILDING.md
- LineageOS source: https://github.com/LineageOS/android
- Active device bring-up branch: [bringup/lineage-17-mojito](https://github.com/h1nchek/BlueOS-mojito/tree/bringup/lineage-17-mojito)

---

<div align="center">

**Community project · Not affiliated with Xiaomi, LineageOS, or the BlueOS upstream maintainers.**

**RU:** Независимый проект сообщества. Неофициальная сборка, не связанная с Xiaomi, LineageOS или разработчиками BlueOS.

</div>
