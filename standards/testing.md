# Testing Standards

Unit testing conventions for ap-* projects.

## Framework

Use pytest with pytest-cov for coverage.

## Directory Structure

```
tests/
├── __init__.py
├── test_<module>.py
└── fixtures/          # Test data files (use Git LFS)
    └── sample.fits
```

## Test Isolation

Tests must be completely isolated:

| Rule | Rationale |
|------|-----------|
| No real filesystem access | Tests must not read/write outside `tmp_path` |
| No mutation of source files | Never modify files in the repo |
| No persistent state | Each test starts clean |
| All created files are cleaned up | Use `tmp_path` fixture for automatic cleanup |

Use pytest's `tmp_path` fixture for any file operations:

```python
def test_copy_file(tmp_path):
    source = tmp_path / "source.fits"
    source.write_bytes(b"test")
    dest = tmp_path / "dest.fits"

    copy_file(str(source), str(dest))

    assert dest.exists()
```

## Test Data (Fixtures)

Store test data files in `tests/fixtures/` using Git LFS:

```bash
git lfs track "tests/fixtures/*.fits"
git lfs track "tests/fixtures/*.xisf"
```

Keep fixture files minimal - only what's needed to test functionality.

## Naming

| Item | Pattern | Example |
|------|---------|---------|
| Test files | `test_<module>.py` | `test_move.py` |
| Test functions | `test_<function>_<scenario>` | `test_build_path_missing_camera_raises` |
| Test classes | `Test<Class>` | `TestMetadataExtraction` |

## Test Organization

One test file per module:

```
ap_<name>/
├── move.py
└── config.py

tests/
├── test_move.py
└── test_config.py
```

## Coverage

Target 80%+ line coverage.

```bash
make coverage
```

## What to Test

- Public functions and methods
- Edge cases (empty input, missing keys)
- Error conditions (raises appropriate exceptions)

## What Not to Test

- Private functions (test through public interface)
- Third-party library behavior
- Configuration constants
