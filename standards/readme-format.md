# README Format

Standard structure for ap-* project READMEs.

## Structure

1. Title
2. Badges
3. Brief description (1-2 sentences)
4. Overview (what it does, key features)
5. Installation
6. Usage (with examples)
7. Related Projects (boilerplate link to ap-base)

## Title

Use the package name as the title:

```markdown
# ap-<name>
```

Do not use prose titles like "Light Frame Organization Tool".

## Badges

Six standard badges, in this order:

```markdown
[![Test](https://github.com/jewzaam/ap-<name>/workflows/Test/badge.svg)](https://github.com/jewzaam/ap-<name>/actions/workflows/test.yml)
[![Coverage](https://github.com/jewzaam/ap-<name>/workflows/Coverage%20Check/badge.svg)](https://github.com/jewzaam/ap-<name>/actions/workflows/coverage.yml)
[![Lint](https://github.com/jewzaam/ap-<name>/workflows/Lint/badge.svg)](https://github.com/jewzaam/ap-<name>/actions/workflows/lint.yml)
[![Format](https://github.com/jewzaam/ap-<name>/workflows/Format%20Check/badge.svg)](https://github.com/jewzaam/ap-<name>/actions/workflows/format.yml)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
```

## Description

One or two sentences immediately after badges. State what the tool does, not implementation details.

Good:
> A tool for organizing light frames based on FITS metadata.

Bad:
> This Python package uses astropy to read FITS headers and organize files into directories.

## Overview

Expand on the description. Cover:
- What problem it solves
- Key features (bulleted list)
- How it fits in the pipeline (if relevant)

Keep it brief. Users want to know what it does, not how.

## Installation

Two methods:

```markdown
## Installation

### Development

\`\`\`bash
make install-dev
\`\`\`

### From Git

\`\`\`bash
pip install git+https://github.com/jewzaam/ap-<name>.git
\`\`\`
```

## Usage

Show the command-line interface with examples:

```markdown
## Usage

\`\`\`bash
python -m ap_<name>.<module> <source_dir> <dest_dir> [options]
\`\`\`

### Options

| Option | Description |
|--------|-------------|
| `--debug` | Enable debug output |
| `--dryrun` | Preview without changes |
```

Include 1-2 concrete examples with real-looking paths.

## Related Projects

Link to the ap-base monorepo for comprehensive documentation:

```markdown
## Related Projects

This project is part of the astrophotography pipeline. See [ap-base](https://github.com/jewzaam/ap-base) for:
- Pipeline overview and workflow documentation
- Links to all pipeline projects
- Cross-project development instructions
```

## What to Avoid

- Implementation details (test file names, internal functions)
- Verbose explanations of obvious things
- Changelog or version history
- Contributor guidelines (use CONTRIBUTING.md if needed)
- Duplicate information from other sections
- License section (LICENSE file exists)
