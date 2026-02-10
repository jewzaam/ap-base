# Makefile Standards

Standard Makefile targets for ap-* Python projects.

## Default Target

Running `make` without specifying a target runs the `default` target, which executes all validation steps (format, lint, typecheck, test, coverage). This ensures code quality checks are easy to run.

```bash
make           # Runs default target (all validations)
make default   # Same as above (explicit)
```

## Required Targets

| Target | Description |
|--------|-------------|
| `default` | Run format, lint, typecheck, test, coverage |
| `install` | Install package |
| `install-dev` | Install in editable mode with dev deps |
| `uninstall` | Uninstall package |
| `clean` | Remove build artifacts |
| `format` | Format code with black |
| `lint` | Lint with flake8 |
| `typecheck` | Type check with mypy |
| `test` | Run pytest |
| `coverage` | Run pytest with coverage |

## Template

Copy [templates/Makefile](templates/Makefile) to your project and replace `<name>` with your project name.

## Conventions

### PYTHON variable

Use `$(PYTHON)` instead of hardcoding `python` or `python3`:

```makefile
PYTHON := python
```

### Dependencies

Targets that need the package installed should depend on `install-dev`:

```makefile
format: install-dev
	$(PYTHON) -m black ap_<name> tests
```

### Quiet failures in clean

Use `|| true` for commands that might fail during cleanup:

```makefile
find . -type d -name __pycache__ -exec rm -r {} + 2>/dev/null || true
```

### Line length

Match black's default of 88 characters:

```makefile
--max-line-length=88
```

## What to Avoid

- Complex shell logic
- Platform-specific commands without fallbacks
- Hardcoded paths
- Targets that modify git state
