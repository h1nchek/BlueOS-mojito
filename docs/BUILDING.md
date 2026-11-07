# Сборка BlueOS для Redmi Note 10 (mojito)

Для краткой передачи проекта сборщику см. [Builder handoff](BUILDER_HANDOFF.md). Для правил внесения изменений см. [CONTRIBUTING.md](../CONTRIBUTING.md).

## Важно

Это экспериментальный порт. Наличие device tree и vendor makefiles не означает, что устройство уже собирается. Успешной полной сборки и проверки загрузки на реальном Redmi Note 10 пока нет.

Upstream BlueOS рекомендует Linux x86_64 (Ubuntu 22.04/24.04), 32 ГБ ОЗУ и около 350 ГБ свободного SSD. Нужен отдельный Linux-компьютер или self-hosted runner; стандартный GitHub-hosted runner не подходит по диску.

## Основной сценарий: одна сборка BlueOS

Для первой полноценной попытки не нужно предварительно собирать чистую LineageOS: это потребовало бы второй полной компиляции. Скрипт по умолчанию сразу подключает закреплённую ревизию BlueOS и собирает целевой ROM:

```bash
ROOT="/path/to/BlueOS-mojito"
JOBS=8 "$ROOT/scripts/build.sh" "$HOME/android/mojito-blueos"
```

То же самое можно указать явно:

```bash
BUILD_STAGE=blueos JOBS=8 "$ROOT/scripts/build.sh" "$HOME/android/mojito-blueos"
```

Скрипт синхронизирует LineageOS 24.0, пять device/kernel/vendor-репозиториев и зафиксированный commit BlueOS. Затем он применяет адресное исправление VINTF manifest ordering, подключает `vendor/blueos/config/blueos.mk` и запускает `breakfast mojito` и `m bacon`.

При загрузке окружения BlueOS автоматически запускает `vendor/blueos/scripts/apply-patches.sh`. В логе должны быть строки `BlueOS: applied …` и не должно быть `BlueOS: FAILED`. Любая ошибка применения патча — причина остановить проверку и сохранить лог, а не считать результат BlueOS-сборкой.

## Дополнительный режим диагностики: чистая LineageOS

Если сборка BlueOS падает и нужно понять, связана ли проблема с базовым device tree или с интеграцией BlueOS, можно выполнить отдельную чистую сборку:

```bash
BUILD_STAGE=lineage JOBS=8 "$ROOT/scripts/build.sh" "$HOME/android/mojito-lineage"
```

Это **дополнительная вторая полная сборка**, а не обязательный шаг основного сценария. Она использует отдельный каталог и не подключает BlueOS. Успешная LineageOS-сборка помогает локализовать проблемы, но сама по себе не создаёт BlueOS ZIP.

Не запускайте оба режима в одном каталоге: они должны иметь отдельные рабочие деревья.

## GitHub Actions

Откройте Actions → Build BlueOS for Redmi Note 10 (mojito) → Run workflow. Параметр stage:
- `blueos` — основной одноразовый билд BlueOS (значение по умолчанию);
- `lineage` — дополнительная чистая LineageOS для диагностики.

Workflow требует self-hosted runner с метками `self-hosted`, `linux`, `x64`, `android-build`, x86_64 Linux, не менее 32 GiB RAM и 350 GiB свободного SSD в RUNNER_TEMP, Android repo, Git, Python 3, Java и системные пакеты для сборки Android. Он сохраняет лог и разрешённый manifest; для ZIP дополнительно создаётся SHA256SUMS.txt.

Стандартные GitHub-hosted runners не подходят для полной Android-сборки по требованиям к диску. Если runner не зарегистрирован и не online, запуск останется в очереди. Сборщик может выполнить тот же скрипт напрямую на своём Linux-хосте и передать ZIP, checksum, лог и resolved manifest — постоянное обслуживание или регулярные сборки не требуются.

## Перед публикацией

- Проверить proprietary blobs, контрольные суммы, ELF-зависимости, firmware и ABI.
- Убедиться, что BlueOS patches применились без ошибок и полная команда сборки завершилась с кодом 0.
- Проверить ZIP, состав архива и SHA-256.
- Провести тест загрузки и проверить связь, Wi-Fi, Bluetooth, камеру, звук, датчики, отпечаток, шифрование и OTA на точном устройстве.

Не устанавливайте непроверенный ZIP. Успешная компиляция не равна успешной загрузке или аппаратному тестированию.
