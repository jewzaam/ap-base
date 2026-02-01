# ap-common Usage

All ap-* projects must use constants and utilities from `ap-common` rather than redefining them locally.

## Rationale

- **Consistency** - All projects use identical values for headers, types, and patterns
- **Maintainability** - Changes propagate automatically when ap-common is updated
- **Discoverability** - Single source of truth for all shared definitions

## Required Dependency

Every ap-* project (except ap-common itself) must include ap-common as a dependency:

```toml
# pyproject.toml
[project]
dependencies = [
    "ap-common",
]
```

## Constants to Import

Never define these locally. Always import from `ap_common`:

### FITS Header Keys

| Constant | Value | Use |
|----------|-------|-----|
| `HEADER_DATE_OBS` | `"DATE-OBS"` | Observation timestamp |
| `HEADER_IMAGETYP` | `"IMAGETYP"` | Frame type |
| `HEADER_TELESCOP` | `"TELESCOP"` | Telescope/optic name |
| `HEADER_INSTRUME` | `"INSTRUME"` | Camera/instrument |
| `HEADER_OBJECT` | `"OBJECT"` | Target name |
| `HEADER_FILTER` | `"FILTER"` | Filter name |
| `HEADER_EXPOSURE` | `"EXPOSURE"` | Exposure time |
| `HEADER_CCD_TEMP` | `"CCD-TEMP"` | Sensor temperature |

### Normalized Header Names

| Constant | Value | Use |
|----------|-------|-----|
| `NORMALIZED_HEADER_DATE` | `"date"` | Normalized date key |
| `NORMALIZED_HEADER_TYPE` | `"type"` | Normalized type key |
| `NORMALIZED_HEADER_OPTIC` | `"optic"` | Normalized optic key |
| `NORMALIZED_HEADER_CAMERA` | `"camera"` | Normalized camera key |
| `NORMALIZED_HEADER_FILTER` | `"filter"` | Normalized filter key |

### Image Type Constants

| Constant | Value | Use |
|----------|-------|-----|
| `TYPE_LIGHT` | `"LIGHT"` | Light frame type |
| `TYPE_DARK` | `"DARK"` | Dark frame type |
| `TYPE_FLAT` | `"FLAT"` | Flat frame type |
| `TYPE_BIAS` | `"BIAS"` | Bias frame type |
| `TYPE_MASTER_DARK` | `"MASTER DARK"` | Stacked dark |
| `TYPE_MASTER_FLAT` | `"MASTER FLAT"` | Stacked flat |
| `TYPE_MASTER_BIAS` | `"MASTER BIAS"` | Stacked bias |

### Type Lists

| Constant | Contents | Use |
|----------|----------|-----|
| `CALIBRATION_TYPES` | `[DARK, FLAT, BIAS]` | Raw calibration frames |
| `MASTER_CALIBRATION_TYPES` | `[MASTER DARK, ...]` | Stacked calibration frames |
| `ALL_CALIBRATION_TYPES` | Both lists combined | Any calibration frame |

### File Extensions

| Constant | Value | Use |
|----------|-------|-----|
| `FILE_EXTENSION_FITS` | `".fits"` | FITS file extension |
| `FILE_EXTENSION_XISF` | `".xisf"` | XISF file extension |
| `DEFAULT_FITS_PATTERN` | `r".*\.fits$"` | FITS file regex |

### Directory Constants

| Constant | Value | Use |
|----------|-------|-----|
| `DIRECTORY_ACCEPT` | `"accept"` | Accepted frames directory |

## Import Examples

```python
# Import specific constants
from ap_common import (
    HEADER_IMAGETYP,
    TYPE_LIGHT,
    TYPE_DARK,
    CALIBRATION_TYPES,
)

# Use in code
if headers[HEADER_IMAGETYP] == TYPE_LIGHT:
    process_light_frame(file)
elif headers[HEADER_IMAGETYP] in CALIBRATION_TYPES:
    process_calibration_frame(file)
```

## Anti-patterns

Do not do this:

```python
# BAD: Redefining constants locally
IMAGETYP = "IMAGETYP"
LIGHT_TYPE = "LIGHT"

# BAD: Using string literals directly
if headers["IMAGETYP"] == "LIGHT":
    ...
```

Instead:

```python
# GOOD: Import from ap_common
from ap_common import HEADER_IMAGETYP, TYPE_LIGHT

if headers[HEADER_IMAGETYP] == TYPE_LIGHT:
    ...
```

## Adding New Constants

When a new constant is needed across multiple projects:

1. Add it to `ap_common/constants.py`
2. Export it in `ap_common/__init__.py`
3. Update all projects to import from ap-common
4. Remove any local definitions
