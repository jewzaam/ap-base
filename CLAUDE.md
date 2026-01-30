# Claude Code Context for ap-base

## Purpose

This repository serves as a monorepo aggregating all astrophotography pipeline projects as git submodules. Its primary purposes are:

1. Provide a single place to collect context for ensuring consistency across projects
2. Provide overarching documentation
3. Enable cross-project analysis and coordination

## Repository Structure

```
ap-base/
├── ap-common/           # Shared utilities and common code
├── ap-cull-lights/      # Light frame selection/culling
├── ap-fits-headers/     # FITS header management
├── ap-master-calibration/  # Master calibration frame creation
├── ap-move-calibration/ # Calibration frame organization
├── ap-move-lights/      # Light frame organization
├── legacy/
│   └── brave-new-world/ # Legacy codebase for reference
├── patches/             # Git patches organized by branch name
├── Makefile             # Patch application workflow
├── CLAUDE.md            # This file (workflow instructions)
├── PATCHING.md          # Detailed patching workflow documentation
└── .gitmodules          # Submodule configuration
```

## Upstream

- Upstream owner: `jewzaam`
- Fork owner: `thelenorith`
- All submodules reference the upstream `jewzaam` repos
- Patches are pushed to `thelenorith` fork branches

## Multi-Repo Workflow with Claude Sessions

### Limitation

Claude Code sessions are scoped to a single repository for git push access. When working from `ap-base`, changes can be analyzed and prepared for submodules, but cannot be pushed directly to them.

### Patch-Based Workflow

Changes for submodules are stored as git patches in `patches/`. This allows:
- Precise, reviewable diffs
- Automated application via Makefile
- Local execution bypasses session limitations

### Patches Directory

Patches are organized by branch name in subdirectories:

```
patches/
├── readme-crosslinks-20260130/
│   ├── ap-common.patch
│   ├── ap-cull-lights.patch
│   └── ...
└── makefile-fixes-20260201/
    └── ap-common.patch
```

Branch naming convention: `<description>-<YYYYMMDD>`

### Quick Reference

```bash
# Clean slate - ALWAYS start here
make deinit
make init

# Check available patches
make status
make status BRANCH=readme-crosslinks-20260130

# Apply and push patches
make apply-patches BRANCH=readme-crosslinks-20260130
make push-patches BRANCH=readme-crosslinks-20260130

# Reset submodules
make clean-patches
```

**See [PATCHING.md](PATCHING.md) for detailed workflow documentation.**

### Creating Patches (Claude Sessions)

When working in a Claude session, always start with clean submodules:

```bash
make deinit
make init
```

Then create patches following the workflow in [PATCHING.md](PATCHING.md).

## Consistency Standards

### Required Files

All ap-* Python projects should have:

| File | Purpose |
|------|---------|
| `LICENSE` | Apache-2.0 license file |
| `README.md` | Project documentation with badges |
| `MANIFEST.in` | Package manifest for sdist |
| `Makefile` | Standard build/test targets |
| `pyproject.toml` | Project configuration |
| `.github/workflows/` | CI workflows (test, lint, format, coverage) |

### pyproject.toml Structure

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "ap-<name>"
version = "0.1.0"
description = "..."
readme = "README.md"
requires-python = ">=3.10"
license = {text = "Apache-2.0"}
authors = [
    {name = "Naveen Malik"}
]
keywords = ["astrophotography", ...]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Science/Research",
    "License :: OSI Approved :: Apache Software License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Programming Language :: Python :: 3.13",
    "Programming Language :: Python :: 3.14",
]
```

### Makefile Structure

All Python projects should use this Makefile pattern:

```makefile
.PHONY: install install-dev install-deps uninstall clean format lint test test-verbose test-coverage coverage default

PYTHON := python

default: format lint test coverage

install:
	$(PYTHON) -m pip install .

install-dev:
	$(PYTHON) -m pip install -e ".[dev]"

install-deps:
	$(PYTHON) -m pip install -e ".[dev]"

uninstall:
	$(PYTHON) -m pip uninstall -y <package-name>

clean:
	rm -rf build/ dist/ *.egg-info <package_name>.egg-info
	find . -type d -name __pycache__ -exec rm -r {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true

format: install-dev
	$(PYTHON) -m black <package_name> tests

lint: install-dev
	$(PYTHON) -m flake8 --jobs=1 --max-line-length=88 --extend-ignore=E203,E266,E501,W503,F401,W605,E722 <package_name> tests

test: install-dev
	$(PYTHON) -m pytest

test-verbose: install-dev
	$(PYTHON) -m pytest -v

test-coverage: install-dev
	$(PYTHON) -m pytest --cov=<package_name> --cov-report=html --cov-report=term

coverage: install-dev
	$(PYTHON) -m pytest --cov=<package_name> --cov-report=term
```

### README Structure

READMEs should include:
1. Title with project name
2. Status badges (Test, Coverage, Lint, Format, Python version, code style)
3. Brief description
4. Overview section
5. Installation section (dev install, pip install from git)
6. Usage section with examples
7. Uninstallation section

Badge format:
```markdown
[![Test](https://github.com/jewzaam/<repo>/workflows/Test/badge.svg)](https://github.com/jewzaam/<repo>/actions/workflows/test.yml)
[![Coverage](https://github.com/jewzaam/<repo>/workflows/Coverage%20Check/badge.svg)](https://github.com/jewzaam/<repo>/actions/workflows/coverage.yml)
[![Lint](https://github.com/jewzaam/<repo>/workflows/Lint/badge.svg)](https://github.com/jewzaam/<repo>/actions/workflows/lint.yml)
[![Format](https://github.com/jewzaam/<repo>/workflows/Format%20Check/badge.svg)](https://github.com/jewzaam/<repo>/actions/workflows/format.yml)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
```

## Working with Submodules

```bash
# After cloning ap-base, initialize submodules
git submodule update --init --recursive

# Update all submodules to latest commits on their default branch
git submodule update --remote

# Pull latest for each submodule
git submodule foreach git pull origin main
```
