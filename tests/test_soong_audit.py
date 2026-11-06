import importlib.util
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "audit-soong-deps.py"
SPEC = importlib.util.spec_from_file_location("soong_audit", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(MODULE)


class SoongAuditTests(unittest.TestCase):
    def test_indexes_module_names_and_dependency_arrays(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "Android.bp"
            path.write_text(
                'cc_prebuilt_library_shared {\n'
                '  name: "libalpha",\n'
                '  shared_libs: ["libbeta", "libc"],\n'
                '  static_libs: ["libsupport"],\n'
                '}\n'
                'cc_library { name: "libbeta" }\n'
            )
            modules = MODULE.parse_modules(path)
            self.assertEqual([item.name for item in modules], ["libalpha", "libbeta"])
            self.assertEqual(
                modules[0].dependencies["shared_libs"], ["libbeta", "libc"]
            )
            self.assertEqual(
                modules[0].dependencies["static_libs"], ["libsupport"]
            )

    def test_ignores_nested_properties_and_comments(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "Android.bp"
            path.write_text(
                '// comment with fake_module { name: "bad" }\n'
                'cc_library {\n'
                ' name: "real",\n'
                ' target: { android: { shared_libs: ["nested"] } },\n'
                ' shared_libs: ["actual"],\n'
                '}\n'
            )
            modules = MODULE.parse_modules(path)
            self.assertEqual(len(modules), 1)
            self.assertEqual(modules[0].name, "real")
            self.assertEqual(modules[0].dependencies["shared_libs"], ["actual"])

    def test_strict_mode_flags_unindexed_dependency(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "Android.bp"
            path.write_text(
                'cc_library { name: "libalpha", shared_libs: ["libexternal"] }'
            )
            modules = MODULE.parse_modules(path)
            self.assertEqual(len(modules), 1)
            self.assertEqual(
                modules[0].dependencies["shared_libs"], ["libexternal"]
            )


if __name__ == "__main__":
    unittest.main()
