#!/usr/bin/env python3
"""Apply the mojito SM6150 device-manifest ordering fix after repo sync."""
from pathlib import Path

target = Path("device/xiaomi/sm6150-common/BoardConfigCommon.mk")
if not target.is_file():
    raise SystemExit(f"ERROR: expected device tree file not found: {target}")

text = target.read_text()
broken = """DEVICE_MANIFEST_FILE += hardware/qcom-caf/sm8150/media/conf_files/sm6150/c2_manifest_vendor.xml
DEVICE_MATRIX_FILE := hardware/qcom-caf/common/compatibility_matrix.xml
DEVICE_MANIFEST_FILE := $(COMMON_PATH)/configs/manifests/manifest.xml"""
fixed = """DEVICE_MANIFEST_FILE := $(COMMON_PATH)/configs/manifests/manifest.xml
DEVICE_MANIFEST_FILE += hardware/qcom-caf/sm8150/media/conf_files/sm6150/c2_manifest_vendor.xml
DEVICE_MATRIX_FILE := hardware/qcom-caf/common/compatibility_matrix.xml"""

if text.count(broken) == 1:
    target.write_text(text.replace(broken, fixed, 1))
elif text.count(fixed) == 1:
    print("SM6150 device manifest ordering already fixed.")
else:
    raise SystemExit(
        "ERROR: BoardConfigCommon.mk differs from the expected source; "
        "refusing to apply an uncertain patch."
    )

print("Applied/verified SM6150 C2 vendor manifest inclusion.")
