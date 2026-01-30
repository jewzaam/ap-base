# CLI Standards

Command-line interface conventions for ap-* tools.

## Argument Style

Use hyphens to separate qualifiers in compound arguments:

| Type | Example | Rule |
|------|---------|------|
| Single concept | `--dryrun`, `--debug` | No hyphens |
| Qualified/compound | `--no-overwrite`, `--blink-dir` | Hyphen separates qualifier |

## Standard Arguments

All CLI tools must support:

| Argument | Type | Description |
|----------|------|-------------|
| `--debug` | flag | Enable debug output |
| `--dryrun` | flag | Perform dry run without side effects |

## Argument Naming

| Pattern | Example | Use |
|---------|---------|-----|
| `--<word>` | `--debug`, `--dryrun` | Single-concept flags |
| `--no-<feature>` | `--no-overwrite`, `--no-accept` | Disable default behavior |
| `--<qualifier>-dir` | `--blink-dir`, `--accept-dir` | Directory paths |

## Positional Arguments

Source and destination directories are positional, not flags.

## Help Text

- Start with lowercase
- No period at end
- Keep under 60 characters

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error |
