# CLI Standards

Command-line interface conventions for ap-* tools.

## Argument Style

Use hyphens to separate qualifiers in compound arguments:

```python
# Single concepts - no hyphens
parser.add_argument("--dryrun", ...)
parser.add_argument("--debug", ...)

# Qualified/compound - use hyphens
parser.add_argument("--no-overwrite", ...)   # "no" qualifies "overwrite"
parser.add_argument("--blink-dir", ...)      # "blink" qualifies "dir"
parser.add_argument("--no-accept", ...)      # "no" qualifies "accept"
```

## Standard Arguments

All CLI tools should support these common arguments:

| Argument | Type | Description |
|----------|------|-------------|
| `--debug` | flag | Enable debug output |
| `--dryrun` | flag | Perform dry run without side effects |
| `--help` | flag | Show help (provided by argparse) |

### Positional Arguments

Source and destination directories are positional:

```python
parser.add_argument("source_dir", type=str, help="Source directory")
parser.add_argument("dest_dir", type=str, help="Destination directory")
```

### Optional Arguments

Use `--` prefix for optional arguments:

```python
parser.add_argument("--no-overwrite", action="store_true",
                    help="fail if destination files exist")
parser.add_argument("--filter", type=str,
                    help="filter by name")
```

## Argument Naming

| Pattern | Example | Use |
|---------|---------|-----|
| `--<word>` | `--debug`, `--dryrun` | Single-concept flags |
| `--no-<feature>` | `--no-overwrite`, `--no-accept` | Disable default behavior |
| `--<noun>` | `--filter`, `--camera` | Value arguments |
| `--<qualifier>-dir` | `--blink-dir`, `--accept-dir` | Directory paths |

## Help Text

- Start with lowercase
- No period at end
- Be concise

```python
# Correct
help="enable debug output"
help="source directory containing FITS files"

# Incorrect
help="Enable debug output."  # No capital, no period
help="This is the source directory where your FITS files are located"  # Too verbose
```

## Variable Names

Argparse converts hyphens to underscores for attribute access:

```python
parser.add_argument("--dryrun", ...)        # args.dryrun
parser.add_argument("--no-overwrite", ...)  # args.no_overwrite
parser.add_argument("--blink-dir", ...)     # args.blink_dir

# Function parameters use snake_case
def process(source_dir: str, dryrun: bool = False, no_overwrite: bool = False):
    ...
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |

```python
import sys

try:
    main()
except Exception as e:
    logger.error(f"{e}")
    sys.exit(1)
```

## Example Parser

```python
import argparse

def main():
    parser = argparse.ArgumentParser(
        description="Copy and organize calibration frames"
    )

    # Positional arguments
    parser.add_argument("source_dir", type=str,
                        help="source directory containing files")
    parser.add_argument("dest_dir", type=str,
                        help="destination directory")

    # Standard flags
    parser.add_argument("--debug", action="store_true",
                        help="enable debug output")
    parser.add_argument("--dryrun", action="store_true",
                        help="perform dry run without copying")

    # Tool-specific flags
    parser.add_argument("--no-overwrite", action="store_true",
                        help="fail if destination files exist")
    parser.add_argument("--blink-dir", type=str, default="10_Blink",
                        help="directory name for blink stage")

    args = parser.parse_args()
```
