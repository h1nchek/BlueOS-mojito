# BlueOS for Xiaomi Redmi Note 10 (mojito / sunny)

Экспериментальный порт BlueOS на базе LineageOS 24.0 для Xiaomi Redmi Note 10 4G (Snapdragon 678).

**Статус:** исходники и проверки подготовлены; полной сборки, ZIP и теста загрузки пока нет.

## Что уже проверено

- Сопоставлены device tree, common tree, kernel и vendor repos для mojito.
- Все 455 конкретных source paths из двух vendor makefiles найдены в текущих GitHub vendor trees (это проверка наличия файлов, не ABI/firmware/runtime).
- Добавлены preflight-аудиторы vendor paths, VINTF XML, Soong module references и local repo manifests.
- Добавлен защищённый патчер порядка SM6150 Codec2 VINTF manifest declarations.
- GitHub Actions preflight: Python compilation, shell syntax, XML/local manifest checks и 29 unit tests. Последний известный run #28 завершился успешно.
- Добавлен ручной build workflow с двумя этапами: чистая LineageOS и BlueOS.

## Что ещё не доказано

- Полная сборка LineageOS 24.0 для mojito.
- Успешное применение всех BlueOS patches на этом дереве.
- Полная сборка BlueOS и получение installable ZIP.
- Загрузка и работа оборудования на физическом Redmi Note 10.

Не называйте этот проект готовой прошивкой, пока эти этапы не пройдены.

## Быстрый старт для билдера

Требуется Linux x86_64, ориентировочно 32 GiB RAM и 350 GiB свободного SSD, Android repo и Android build dependencies.

1. Клонировать этот репозиторий.
2. Сначала запустить BUILD_STAGE=lineage JOBS=8 scripts/build.sh /path/to/lineage.
3. После успешной базовой сборки запустить BUILD_STAGE=blueos JOBS=8 scripts/build.sh /path/to/blueos.
4. Сохранить полный build log и resolved-manifest-blueos.xml, проверить ZIP и SHA-256.
5. Передавать ZIP только как экспериментальный build для тестирования; не заявлять о рабочем железе без тестов на устройстве.

Подробности: [docs/BUILDING.md](docs/BUILDING.md).

## Исходники

- [BlueOS upstream](https://github.com/GDmio/BlueOS)
- [Device tree](https://github.com/ximi-mojito/device_xiaomi_mojito)
- [SM6150 common tree](https://github.com/ximi-mojito/device_xiaomi_sm6150-common)
- [Kernel](https://github.com/ximi-mojito/android_kernel_xiaomi_mojito)
- [Device vendor](https://github.com/ximi-mojito/android_vendor_xiaomi_mojito)
- [Common vendor](https://github.com/ximi-mojito/android_vendor_xiaomi_sm6150-common)

Original project glue, scripts and documentation in this repository are Apache-2.0 unless otherwise noted. Third-party source trees and proprietary blobs retain their own licenses and redistribution terms.
