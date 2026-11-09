# Сборка BlueOS для Redmi Note 10 (mojito)

Для краткой передачи проекта добровольному сборщику см. [Builder handoff](BUILDER_HANDOFF.md). Для правил внесения изменений см. [CONTRIBUTING.md](../CONTRIBUTING.md).

## Важно

Это экспериментальный порт. Наличие device tree и vendor makefiles не означает, что устройство уже собирается. Успешной полной сборки и проверки загрузки на реальном Redmi Note 10 пока нет.

Upstream BlueOS рекомендует Linux x86_64 (Ubuntu 22.04/24.04), 32 ГБ ОЗУ и около 350 ГБ свободного SSD. Для сборки нужен отдельный Linux-компьютер или self-hosted runner; стандартный GitHub-hosted runner не подходит по диску.

## Два независимых этапа

Сначала нужно проверить чистую LineageOS 24.0, и только после этого — BlueOS. Скрипт scripts/build.sh поддерживает оба этапа через BUILD_STAGE. Если переменная не задана, по умолчанию запускается безопасный первый этап — чистая LineageOS; BlueOS нужно выбирать явно.

### 1. Чистая LineageOS

```bash
ROOT="/path/to/BlueOS-mojito"
BUILD_STAGE=lineage JOBS=8 "$ROOT/scripts/build.sh" "$HOME/android/mojito-lineage"
```

На этом этапе синхронизируются только LineageOS и исходники устройства. Репозиторий BlueOS не подключается, vendor/extra/product.mk не изменяется, патчи BlueOS не применяются. Успешная сборка этого этапа подтверждает только базовую сборку LineageOS для mojito.

### 2. BlueOS

После успешной базовой сборки запускается отдельный этап в отдельном каталоге:

```bash
BUILD_STAGE=blueos JOBS=8 "$ROOT/scripts/build.sh" "$HOME/android/mojito-blueos"
```

Он синхронизирует LineageOS, device sources и зафиксированную ревизию BlueOS, добавляет строку inherit-product и запускает сборку. BlueOS автоматически запускает vendor/blueos/scripts/apply-patches.sh при загрузке окружения. В выводе должны быть строки BlueOS: applied … и не должно быть BlueOS: FAILED.

Разделение каталогов важно: базовая LineageOS и BlueOS не должны случайно наследовать состояние друг друга.

## Исходники и ревизии

- LineageOS manifest: lineage-24.0.
- Device/common/kernel/vendor repos: immutable commit SHAs, resolved from branch 17.0 on 2026-11-09 and recorded in manifests/mojito-lineage24.xml.
- BlueOS: фиксированный commit SHA в manifests/blueos.xml, чтобы повторные сборки не меняли исходники незаметно.

После repo sync скрипт сохраняет разрешённый manifest с точными SHA проектов в resolved-manifest-lineage.xml или resolved-manifest-blueos.xml в корне репозитория. Workflow прикладывает этот файл к артефактам сборки. До загрузки исходников скрипт проверяет структуру локальных XML-манифестов; после синхронизации проверяет наличие всех конкретных vendor blob paths, исправляет известный порядок SM6150 VINTF manifest declarations и выполняет структурную проверку двух VINTF XML. Эти проверки останавливают сборку при найденной ошибке, но не заменяют полноценные Make/Soong и checkvintf проверки.

Ветка устройства 17.0 сама по себе ещё не доказывает совместимость с каждым проектом LineageOS 24.0. Сначала проверьте чистую базовую сборку. Если она не собирается, сначала исправьте ошибки device/vendor/kernel-интеграции и только затем переходите к BlueOS.

## Устройство и VINTF

После repo sync выполняется адресное исправление порядка common и Qualcomm SM6150 Codec2 manifest declarations:

```bash
python3 "$ROOT/scripts/patch-mojito-device-tree.py"
```

Патчер защищён от повторного применения и от неизвестного состояния файла. Он не заменяет проверку checkvintf в полном Android tree.

## Fallback для патчей BlueOS 0.8.1

Если apply-patches.sh сообщает BlueOS: FAILED, не применяйте fallback вслепую. Сначала сохраните полный лог и проверьте, какой именно патч конфликтует. При необходимости можно временно использовать manifests/blueos-pinned.xml, который фиксирует 12 общих проектов на ревизиях, под которые готовились патчи BlueOS 0.8.1:

```bash
cp "$ROOT/manifests/blueos-pinned.xml" .repo/local_manifests/
repo sync -j8 --force-sync
source build/envsetup.sh
```

Этот fallback не проверялся через реальный repo sync и может потребовать адаптации. Он предназначен только для проектов, которые патчит BlueOS, а не для отката всего дерева.

## GitHub Actions

Откройте Actions → Build BlueOS for Redmi Note 10 (mojito) → Run workflow. По умолчанию выбран `lineage`; параметр stage:
- lineage — чистая LineageOS без BlueOS;
- blueos — экспериментальная BlueOS.

Workflow требует self-hosted runner с метками self-hosted, linux, x64, android-build, x86_64 Linux, не менее 32 GiB RAM и 350 GiB свободного SSD в RUNNER_TEMP, Android repo, Git, Python 3, Java и установленными системными пакетами для сборки Android. Он сохраняет лог и разрешённый manifest. Для ROM ZIP дополнительно создаётся SHA256SUMS.txt.

Стандартные GitHub-hosted runners не подходят для полной Android-сборки по требованиям к диску. Пока подходящий runner не зарегистрирован и не находится online, запуск полной сборки останется в очереди.

## Перед выпуском

- Проверить proprietary blobs, контрольные суммы, ELF-зависимости, firmware и ABI.
- Успешно собрать чистую LineageOS для mojito.
- Успешно применить все BlueOS patches и собрать BlueOS.
- Проверить ZIP, состав архива и SHA-256.
- Провести тест загрузки и проверить связь, Wi-Fi, Bluetooth, камеру, звук, датчики, отпечаток, шифрование и OTA на точном устройстве.

Не устанавливайте непроверенный ZIP. Сборка на компьютере не равна тестированию на телефоне.
