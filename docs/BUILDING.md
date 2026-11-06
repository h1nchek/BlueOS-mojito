# Сборка BlueOS для Redmi Note 10 (mojito)

## Важно

Это экспериментальный порт. Наличие device tree и vendor makefiles не означает, что устройство уже собирается. Успешной полной сборки и проверки загрузки на реальном Redmi Note 10 пока нет.

Upstream BlueOS рекомендует Linux x86_64 (Ubuntu 22.04/24.04 или WSL2), 32 ГБ ОЗУ и около 350 ГБ свободного SSD.

## Исходники и базовая LineageOS

Ниже `ROOT` — путь к клону этого репозитория `BlueOS-mojito`. Сначала синхронизируй **только** device manifest, чтобы получить чистую LineageOS без BlueOS:

```bash
ROOT="/path/to/BlueOS-mojito"
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs --no-clone-bundle
mkdir -p .repo/local_manifests
cp "$ROOT/manifests/mojito-lineage24.xml" .repo/local_manifests/
repo sync -j8 --fail-fast
python3 "$ROOT/scripts/patch-mojito-device-tree.py"
```

Ветка устройства `17.0` сама по себе ещё не доказывает совместимость с каждым проектом LineageOS 24.0. Сначала попробуй собрать базовый продукт:

```bash
source build/envsetup.sh
breakfast mojito
m bacon -j8
```

The wrapper defaults to at most 8 parallel jobs to limit memory pressure. The documented commands use `-j8`; lower this value on hosts with less RAM.

Если чистая LineageOS не собирается, сначала исправь ошибки device/vendor/kernel-интеграции. Не переходи к BlueOS, пока базовая сборка не проходит.

## Подключение BlueOS

После успешной базовой сборки добавь upstream BlueOS manifest и синхронизируй его проекты:

```bash
cp "$ROOT/manifests/blueos.xml" .repo/local_manifests/
repo sync -j8
python3 "$ROOT/scripts/patch-mojito-device-tree.py"
```

Из корня Android-исходников подключи BlueOS к продукту:

```bash
mkdir -p vendor/extra
grep -qxF '$(call inherit-product, vendor/blueos/config/blueos.mk)' vendor/extra/product.mk 2>/dev/null || echo '$(call inherit-product, vendor/blueos/config/blueos.mk)' >> vendor/extra/product.mk
```

## Сборка BlueOS

```bash
source build/envsetup.sh
breakfast mojito
m bacon -j8
```

BlueOS автоматически запускает `vendor/blueos/scripts/apply-patches.sh` при загрузке окружения. Скрипт возвращает ненулевой код, если хотя бы один патч не применился; не игнорируйте `BlueOS: FAILED`.

Если патчи не применяются на свежей LineageOS, можно временно закрепить только патчимые проекты на исходных ревизиях BlueOS 0.8.1:

```bash
PORT_REPO="/path/to/BlueOS-mojito"  # каталог, где лежат manifests/ и scripts/
cp "$PORT_REPO/manifests/blueos-pinned.xml" .repo/local_manifests/
repo sync -j8 --force-sync
source build/envsetup.sh
```

Здесь `PORT_REPO` — путь к клону этого репозитория. В локальном манифесте используется `extend-project path=...`, чтобы адресовать проекты по путям. Не используйте upstream `manifests/blueos-pinned.xml` без проверки: в текущем upstream-файле у элементов `extend-project` пустые атрибуты `name`, поэтому он не задаёт корректные проекты. Наш исправленный вариант сопоставляет 12 ревизий с путями проектов; SHA проверены по соответствующим репозиториям LineageOS. Сам `repo sync` с этим fallback-манифестом ещё не запускался.

После фиксации ревизий повторно проверьте вывод: не должно быть `BlueOS: FAILED`.

## Перед выпуском

- Проверить полноту proprietary blobs и соответствие firmware.
- Успешно собрать чистую LineageOS для mojito.
- Успешно применить все BlueOS patches.
- Проверить ZIP, состав архива и SHA-256.
- Провести тест загрузки и проверить связь, Wi-Fi, Bluetooth, камеру, звук, датчики, отпечаток, шифрование и OTA на точном устройстве.

Не устанавливайте непроверенный ZIP. Сборка на компьютере не равна тестированию на телефоне.


## GitHub Actions build

A manual workflow is provided at [Build BlueOS for Redmi Note 10](../.github/workflows/build-blueos-mojito.yml). It builds the ROM and uploads any resulting ROM ZIP larger than 100 MiB together with a SHA-256 checksum file as a GitHub Actions artifact.

**Runner requirement:** this workflow intentionally uses a self-hosted runner with labels `self-hosted`, `linux`, `x64`, and `android-build`. Register it on a Linux x86_64 machine with at least 32 GiB RAM, 350 GiB free SSD in `RUNNER_TEMP`, the Android `repo` tool, Git, Python 3, Java, and the Ubuntu/Android build dependencies documented by LineageOS. Standard GitHub-hosted runners do not provide the required disk capacity for this source build. The runner must be online and have all required build packages installed before starting the workflow. The build wrapper defaults to at most 8 parallel jobs to reduce memory pressure; set `JOBS` explicitly only when the runner has enough RAM.

To start it, open the repository's **Actions** tab, select **Build BlueOS for Redmi Note 10 (mojito)**, choose **Run workflow**, and optionally set the parallel job count (0 uses the conservative default of 8 jobs; explicit values override it). When successful, open the completed run and download the `BlueOS-mojito-...` artifact. Verify `SHA256SUMS.txt` before using the ZIP.

The workflow only packages a ZIP that the build actually produced; it does not manufacture a recovery package when the build fails or produces no ROM ZIP. A successful CI build is not proof that the image boots or that device hardware works. Do not flash it until it has been checked and tested on the exact device.
