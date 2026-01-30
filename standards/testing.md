# Testing Standards

Unit testing conventions for ap-* projects.

## Framework

Use pytest with pytest-cov for coverage.

## Directory Structure

```
tests/
├── __init__.py
├── test_<module>.py
└── fixtures/          # Optional: test data files
    └── sample.fits
```

## Naming

- Test files: `test_<module>.py`
- Test functions: `test_<function>_<scenario>`
- Test classes (if grouping): `Test<Class>`

Examples:
```python
def test_build_path_with_valid_metadata():
    ...

def test_build_path_missing_camera_raises():
    ...

class TestMetadataExtraction:
    def test_extracts_exposure_time(self):
        ...
```

## Test Organization

One test file per module. Test file mirrors module structure:

```
ap_<name>/
├── move.py
└── config.py

tests/
├── test_move.py
└── test_config.py
```

## Fixtures

Use pytest fixtures for shared setup:

```python
import pytest

@pytest.fixture
def sample_metadata():
    return {
        "camera": "ASI2600MM",
        "exposure": 300,
        "filter": "L",
    }

def test_build_filename(sample_metadata):
    result = build_filename(sample_metadata)
    assert "ASI2600MM" in result
```

## Mocking

Mock external dependencies (filesystem, network):

```python
from unittest.mock import patch, MagicMock

def test_copy_file_creates_directory(tmp_path):
    source = tmp_path / "source.fits"
    source.write_bytes(b"test")
    dest = tmp_path / "subdir" / "dest.fits"

    copy_file(str(source), str(dest))

    assert dest.exists()
```

Prefer `tmp_path` fixture over mocking filesystem when possible.

## Coverage

Target 80%+ line coverage. Run with:

```bash
make coverage
```

Coverage reports show term output. HTML reports available via:

```bash
make test-coverage
```

## What to Test

- Public functions and methods
- Edge cases (empty input, missing keys)
- Error conditions (invalid input raises appropriate exceptions)
- Integration between modules

## What Not to Test

- Private functions (test through public interface)
- Third-party library behavior
- Simple property accessors
- Configuration constants
