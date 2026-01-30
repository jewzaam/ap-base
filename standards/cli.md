# CLI Standards

Command-line interface conventions for ap-* tools.

## Argument Style

Use lowercase with no hyphens for flag names:

```python
# Correct
parser.add_argument("--dryrun", ...)
parser.add_argument("--debug", ...)
parser.add_argument("--nooverwrite", ...)

# Incorrect
parser.add_argument("--dry-run", ...)   # No hyphens
parser.add_argument("--dry_run", ...)   # No underscores
parser.add_argument("--DryRun", ...)    # No camelCase
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
parser.add_argument("--nooverwrite", action="store_true",
                    help="Fail if destination files exist")
parser.add_argument("--filter", type=str,
                    help="Filter by name")
```

## Argument Naming

| Pattern | Example | Use |
|---------|---------|-----|
| `--<action>` | `--debug`, `--dryrun` | Boolean flags |
| `--no<feature>` | `--nooverwrite`, `--noaccept` | Disable default behavior |
| `--<noun>` | `--filter`, `--camera` | Value arguments |
| `--<noun>dir` | `--blinkdir`, `--acceptdir` | Directory paths |

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

Internal variable names use snake_case to match Python conventions:

```python
parser.add_argument("--dryrun", ...)  # CLI: no hyphen
args.dryrun  # Access: matches CLI

# Function parameters
def process(source_dir: str, dryrun: bool = False):
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
    parser.add_argument("--nooverwrite", action="store_true",
                        help="fail if destination files exist")

    args = parser.parse_args()
```
