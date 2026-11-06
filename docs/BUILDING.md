# Сборка BlueOS для Redmi Note 10 (mojito)

## Важно

Это экспериментальный порт. Наличие device tree и vendor makefiles не означает, что устройство уже собирается. На момент подготовки инструкции не было успешной полной сборки или проверки загрузки на реальном Redmi Note 10.

Upstream BlueOS заявляет LineageOS 24.0 / Android 17. В upstream-гайде указаны Linux x86_64, около 32 ГБ ОЗУ и примерно 350 ГБ свободного SSD. На слабом хосте сборка может не завершиться.

## Исходники

Из корня клона этого репозитория:

```bash
mkdir -p .repo/local_manifests
cp manifests/mojito-lineage24.xml .repo/local_manifests/
cp manifests/blueos.xml .repo/local_manifests/
```

Инициализировать платформу LineageOS 24.0 и синхронизировать:

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs --no-clone-bundle
repo sync -j8
```

Если `repo sync` сообщает о несовместимых проектах, не продолжать сборку вслепую: сначала проверить, действительно ли все пять device-side проектов ветки `17.0` совместимы с текущей платформой `lineage-24.0`.

## Подключение BlueOS

После синхронизации из корня Android-исходников:

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

Сначала проверьте вывод скриптов BlueOS: не должно быть сообщений `BlueOS: FAILED`. Если сборка остановилась на device-tree, vendor blob или patch error, это блокер порта, а не повод отключать SELinux или пропускать проверки безопасности.

## Что нужно проверить перед выпуском

- Наличие всех proprietary blobs, соответствие их версии прошивки и корректность лицензирования.
- Успешную сборку `lineage_mojito` на чистом дереве.
- Успешное применение всех BlueOS patches.
- Существование ожидаемого ZIP в `out/target/product/mojito/`, корректный состав архива и SHA-256.
- Тестовую загрузку и работу связи, Wi-Fi, Bluetooth, камеры, звука, датчиков, отпечатка, шифрования и OTA на точном устройстве.

Не устанавливайте непроверенный ZIP. Сборка на компьютере не равна тестированию на телефоне.
