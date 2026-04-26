# Claude Code Context for ap-base

## Purpose

This repository serves as a monorepo aggregating all astrophotography pipeline projects as git submodules. Its primary purposes are:

1. Provide a single place to collect context for ensuring consistency across projects
2. Provide overarching documentation
3. Enable cross-project analysis and coordination

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
├── docs/                # Centralized documentation (includes docs/standards/)
├── Makefile             # Development and validation targets
├── CLAUDE.md            # This file (workflow instructions)
└── .gitmodules          # Submodule configuration
```

## Upstream

- Upstream owner: `jewzaam`
- Fork owner: `thelenorith`
- All submodules reference the upstream `jewzaam` repos

## Multi-Repo Workflow with Claude Sessions

### Limitation

Claude Code sessions are scoped to a single repository for git push access. When working from `ap-base`, changes can be analyzed and prepared for submodules, but cannot be pushed directly to them.

### Working with Submodules

To make changes to submodules:

1. Initialize submodules with clean state:
   ```bash
   make deinit
   make init
   ```

2. Navigate into the specific submodule:
   ```bash
   cd ap-common
   # make changes, commit, push
   ```

3. Each submodule is its own git repository and can be modified independently.

## Project Standards

AP-specific standards live in [docs/standards/](docs/standards/index.md):

- [ap-common Usage](docs/standards/ap-common-usage.md) - Use shared constants from ap-common

For general software-engineering standards (Python style, naming, project structure, Makefile, GitHub workflows, testing, CLI, versioning, etc.), see [jewzaam/standards](https://github.com/jewzaam/standards).

## Working with Submodules

```bash
# After cloning ap-base, initialize submodules
git submodule update --init --recursive

# Update all submodules to latest commits on their default branch
git submodule update --remote

# Pull latest for each submodule
git submodule foreach git pull origin main
```
