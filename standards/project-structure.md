# Project Structure

Standard directory layout for ap-* Python projects.

## Directory Layout

```
ap-<name>/
├── ap_<name>/              # Package directory (underscores)
│   ├── __init__.py
│   ├── __main__.py         # Entry point for python -m
│   └── <module>.py
├── tests/
│   ├── __init__.py
│   └── test_<module>.py
├── .github/
│   └── workflows/
│       ├── test.yml
│       ├── lint.yml
│       ├── format.yml
│       └── coverage.yml
├── .gitignore
├── LICENSE
├── MANIFEST.in
├── Makefile
├── README.md
└── pyproject.toml
```

## Required Files

| File | Purpose |
|------|---------|
| `LICENSE` | Apache-2.0 license text |
| `README.md` | Project documentation |
| `MANIFEST.in` | sdist inclusion rules |
| `Makefile` | Build/test automation |
| `pyproject.toml` | Package configuration |
| `.gitignore` | Git ignore patterns |

## Naming Conventions

- **Repository**: `ap-<name>` (hyphenated)
- **Package directory**: `ap_<name>` (underscored)
- **Module files**: lowercase, underscored
- **Test files**: `test_<module>.py`

## pyproject.toml

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "ap-<name>"
version = "0.1.0"
description = "<brief description>"
readme = "README.md"
requires-python = ">=3.10"
license = {text = "Apache-2.0"}
authors = [
    {name = "Naveen Malik"}
]
keywords = ["astrophotography"]
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
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-cov>=4.0",
    "black>=23.0",
    "flake8>=6.0",
]

[tool.setuptools.packages.find]
where = ["."]
include = ["ap_<name>*"]
```

## .gitignore

```gitignore
# Python
__pycache__/
*.py[cod]
*.egg-info/
dist/
build/
.eggs/

# Testing
.pytest_cache/
.coverage
htmlcov/

# IDE
.vscode/
.idea/

# Virtual environments
venv/
.venv/
```

## MANIFEST.in

```
include LICENSE
include README.md
recursive-include ap_<name> *.py
```
