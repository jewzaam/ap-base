# ap-base

[![Markdown Lint](https://github.com/jewzaam/ap-base/actions/workflows/markdown-lint.yml/badge.svg)](https://github.com/jewzaam/ap-base/actions/workflows/markdown-lint.yml)
[![Validate Links](https://github.com/jewzaam/ap-base/actions/workflows/links.yml/badge.svg)](https://github.com/jewzaam/ap-base/actions/workflows/links.yml)

Monorepo aggregating all astrophotography pipeline projects as git submodules.

## Purpose

This repository serves three primary functions:

1. **Standards Enforcement** - Define and maintain consistent standards across all projects
2. **Coordinated Changes** - Make synchronized updates across multiple repositories
3. **Centralized Documentation** - Provide overarching documentation for the entire pipeline

## Repository Structure

```text
ap-base/
├── ap-common/                   # Shared utilities and common code
├── ap-copy-master-to-blink/     # Master calibration frame distribution
├── ap-cull-light/               # Light frame selection/culling
├── ap-create-master/            # Master calibration frame creation
├── ap-empty-directory/          # Directory cleanup utility
├── ap-move-light-to-data/       # Light frame data migration
├── ap-move-master-to-library/   # Calibration frame organization
├── ap-move-raw-light-to-blink/  # Light frame organization
├── ap-preserve-header/          # FITS header management
├── docs/                   # Centralized documentation (includes docs/standards/)
├── Makefile                # Submodule management
└── CLAUDE.md               # Claude Code workflow instructions
```

## Getting Started

### Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd ap-base

# Initialize and update all submodules
make init
```

### Clean Slate

To reset all submodules to a clean state:

```bash
make deinit  # Deinitialize submodules and clear cache
make init    # Reinitialize fresh submodules
```

## Working with Standards

AP-specific standards live in [`docs/standards/`](docs/standards/index.md):

- [ap-common Usage](docs/standards/ap-common-usage.md) - Use shared constants from ap-common

For general software-engineering standards (project structure, README format, Makefile, GitHub workflows, testing, CLI, naming, etc.), see [jewzaam/standards](https://github.com/jewzaam/standards).

### Enforcing Standards

When making changes to submodule projects:

1. Review AP-specific standards in [`docs/standards/`](docs/standards/index.md) and general standards at [jewzaam/standards](https://github.com/jewzaam/standards)
2. Ensure changes conform to established conventions
3. Update standards documentation if introducing new patterns
4. Apply changes consistently across all affected submodules

## Making Coordinated Changes

This repository enables synchronized updates across multiple projects:

### Workflow for Cross-Repository Changes

1. **Identify affected submodules** - Determine which projects need updates
2. **Review standards** - Ensure changes align with project conventions
3. **Make changes locally** - Update each submodule in your working directory
4. **Test across projects** - Verify changes work correctly in all contexts
5. **Commit and push** - Push changes to each submodule's repository
6. **Update submodule references** - Commit updated submodule pointers in ap-base

### Example: Updating README Format

```bash
# Start with fresh submodules
make deinit
make init

# Make changes to each submodule's README
cd ap-common
# Edit README.md to match the README format standard at https://github.com/jewzaam/standards
git add README.md
git commit -m "Update README to match ap-base standards"
git push

# Repeat for other submodules
cd ../ap-cull-light
# ... make similar changes ...

# Update ap-base to reference new commits
cd ..
git add ap-common ap-cull-light  # ... other updated submodules
git commit -m "Update submodule references after README standardization"
git push
```

## Documentation

Centralized documentation lives in `docs/`:

- [Documentation Index](docs/index.md) - Overview of available documentation
- [Directory Structure](docs/directory-structure.md) - Pipeline directory layout
- [Workflow](docs/workflow.md) - Processing workflow documentation
- [Tools](docs/tools/) - Tool-specific documentation

This documentation provides high-level context that spans multiple projects and doesn't belong in individual submodule READMEs.

## Makefile Targets

```bash
make init    # Initialize and update all submodules to latest
make deinit  # Deinitialize submodules and clear cache
make help    # Show available targets
```

## Contributing

When contributing changes that affect multiple projects:

1. Check standards documentation for existing conventions
2. Make coordinated changes across relevant submodules
3. Update ap-base documentation if introducing new patterns
4. Test changes in context of the full pipeline
5. Update this README if workflow or structure changes
