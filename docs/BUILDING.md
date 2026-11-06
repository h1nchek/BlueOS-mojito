# Сборка BlueOS для Redmi Note 10 (mojito)

## Важно

Это экспериментальный порт. Наличие device tree и vendor makefiles не означает, что устройство уже собирается. Успешной полной сборки и проверки загрузки на реальном Redmi Note 10 пока нет.

Upstream BlueOS рекомендует Linux x86_64 (Ubuntu 22.04/24.04 или WSL2), 32 ГБ ОЗУ и около 350 ГБ свободного SSD.

## Исходники

Из корня клона этого репозитория:

```bash
mkdir -p .repo/local_manifests
cp manifests/mojito-lineage24.xml .repo/local_manifests/
cp manifests/blueos.xml .repo/local_manifests/
```

Инициализировать LineageOS 24.0:

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs --no-clone-bundle
repo sync -j8
```

Сначала нужно получить чистую сборку LineageOS для `mojito`. Ветка устройства `17.0` сама по себе ещё не доказывает совместимость с каждым проектом LineageOS 24.0.

## Подключение BlueOS

Из корня Android-исходников:

```bash
mkdir -p vendor/extra
grep -qxF '$(call inherit-product, vendor/blueos/config/blueos.mk)' vendor/extra/product.mk 2>/dev/null || echo '$(call inherit-product, vendor/blueos/config/blueos.mk)' >> vendor/extra/product.mk
```

## Сборка

```bash
source build/envsetup.sh
breakfast mojito
m bacon -j"$(nproc)"
```

BlueOS автоматически запускает `vendor/blueos/scripts/apply-patches.sh` при загрузке окружения. Скрипт возвращает ненулевой код, если хотя бы один патч не применился; не игнорируйте `BlueOS: FAILED`.

Если патчи не применяются на свежей LineageOS, можно временно закрепить только патчимые проекты на исходных ревизиях BlueOS 0.8.1:

```bash
PORT_REPO="/path/to/BlueOS-mojito"  # каталог, где лежат manifests/ и scripts/
cp "$PORT_REPO/manifests/blueos-pinned.xml" .repo/local_manifests/
repo sync -j8 --force-sync
source build/envsetup.sh
```

Здесь `PORT_REPO` — путь к клону этого репозитория. В локальном манифесте используется `extend-project path=...`, чтобы адресовать проекты по путям. Не используйте upstream `manifests/blueos-pinned.xml` без проверки: в текущем upstream-файле у элементов `extend-project` пустые атрибуты `name`, поэтому он не задаёт корректные проекты. Наш исправленный вариант сопоставляет 12 ревизий с путями из upstream `scripts/export-patches.sh`.

После фиксации ревизий повторно проверьте вывод: не должно быть `BlueOS: FAILED`.

## Перед выпуском

- Проверить полноту proprietary blobs и соответствие firmware.
- Успешно собрать чистую LineageOS для mojito.
- Успешно применить все BlueOS patches.
- Проверить ZIP, состав архива и SHA-256.
- Провести тест загрузки и проверить связь, Wi-Fi, Bluetooth, камеру, звук, датчики, отпечаток, шифрование и OTA на точном устройстве.

Не устанавливайте непроверенный ZIP. Сборка на компьютере не равна тестированию на телефоне.
