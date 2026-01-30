# Patching Workflow

This document describes how to create and apply patches for submodule repositories.

## Overview

Because Claude Code sessions are scoped to a single repository, changes to submodules must be prepared as git patches in `ap-base` and then applied locally by the user.

## Directory Structure

Patches are organized by branch name in subdirectories:

```
patches/
├── readme-crosslinks-20260130/
│   ├── ap-common.patch
│   ├── ap-cull-lights.patch
│   └── ...
├── makefile-fixes-20260201/
│   └── ap-common.patch
└── ...
```

Each subdirectory name becomes the branch name in the target submodule.

## Branch Naming Convention

Use descriptive names with a timestamp suffix:

```
<description>-<YYYYMMDD>
```

Examples:
- `readme-crosslinks-20260130`
- `makefile-standardization-20260201`
- `license-updates-20260215`

## Creating Patches

### 1. Start with clean submodules

Always start from a clean slate to ensure patches apply cleanly:

```bash
make deinit
make init
```

### 2. Make changes in the submodule

```bash
cd <submodule>
# Edit files as needed
```

### 3. Create the patch

For modified files:
```bash
git diff > ../patches/<branch-name>/<submodule>.patch
```

For new files (must stage first, then reset):
```bash
git add -A
git diff --cached > ../patches/<branch-name>/<submodule>.patch
git reset HEAD
```

For both modified and new files:
```bash
git add -A
git diff --cached > ../patches/<branch-name>/<submodule>.patch
git reset HEAD
```

### 4. Create the patches directory if needed

```bash
mkdir -p patches/<branch-name>
```

### 5. Reset the submodule

After creating the patch, reset to ensure the submodule stays clean:

```bash
git checkout .
git clean -fd
```

Or reset all submodules:

```bash
make deinit
make init
```

## Applying Patches

### Apply all patches for a branch

```bash
make apply-patches BRANCH=readme-crosslinks-20260130
```

This will:
1. Initialize submodules if needed
2. For each submodule with a patch in `patches/<BRANCH>/`:
   - Checkout main and pull latest
   - Create/checkout the branch named `<BRANCH>`
   - Apply the patch
   - Stage and commit changes

### Apply to a specific submodule

```bash
make apply-patch-ap-common BRANCH=readme-crosslinks-20260130
```

## Pushing Patches

After applying patches locally, push them to the remote:

### Push all

```bash
make push-patches BRANCH=readme-crosslinks-20260130
```

### Push specific submodule

```bash
make push-patch-ap-common BRANCH=readme-crosslinks-20260130
```

## Checking Status

View available patch directories and their contents:

```bash
make status
```

View patches for a specific branch:

```bash
make status BRANCH=readme-crosslinks-20260130
```

## Cleaning Up

### Reset submodules to main

```bash
make clean-patches
```

### Full reset (deinit and clear cache)

```bash
make deinit
```

## Managing Old Patches

Old patch directories are not automatically deleted. To remove them:

```bash
rm -rf patches/<branch-name>
```

Or ask Claude to clean up specific patch directories when they are no longer needed.

## Workflow Summary

```
1. make deinit                    # Clean slate
2. make init                      # Fresh submodules
3. cd <submodule>                 # Enter submodule
4. # make changes                 # Edit files
5. mkdir -p ../patches/<branch>   # Create patch dir
6. git add -A && git diff --cached > ../patches/<branch>/<submodule>.patch && git reset HEAD
7. cd ..                          # Back to ap-base
8. make deinit && make init       # Reset submodules
9. make apply-patches BRANCH=<branch>   # Test patches apply
10. make push-patches BRANCH=<branch>   # Push to remotes
```

## Troubleshooting

### Patch doesn't apply

If a patch fails to apply, the submodule may have diverged from when the patch was created:

1. Check if the submodule is on the correct commit
2. Try `make deinit && make init` to reset
3. If the upstream has changed, the patch may need to be recreated

### Submodule in dirty state

If submodules have uncommitted changes:

```bash
make deinit
make init
```

### Branch already exists

If the target branch already exists in a submodule, the apply will checkout the existing branch. To start fresh:

```bash
cd <submodule>
git branch -D <branch-name>
cd ..
make apply-patch-<submodule> BRANCH=<branch-name>
```
