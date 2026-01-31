# Patching Workflow

This document describes how to create and apply patches for submodule repositories.

## Overview

Because Claude Code sessions are scoped to a single repository, changes to submodules must be prepared as git patches in `ap-base` and then applied locally by the user.

**Key principle**: Patches are a temporary staging area, not permanent storage. They bridge the gap between Claude sessions and submodule repos, and should be deleted after the submodule changes are merged upstream.

## Directory Structure

Patches use a flat structure with one patch file per submodule:

```
patches/
├── ap-common.patch
├── ap-cull-lights.patch
└── ...
```

**Constraints**:
- Maximum one patch per submodule at a time
- Patches should not accumulate - delete after submodule merges
- If you need multiple changes to the same submodule, merge the first before starting the second

## Patch Lifecycle

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. CLAUDE SESSION                                                           │
│    - Claude makes changes to submodule code                                 │
│    - Claude creates patches/<submodule>.patch                               │
│    - Claude commits patch to ap-base branch                                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. LOCAL APPLICATION (User)                                                 │
│    - make apply-patches                                                     │
│    - make push-patches REMOTE=<fork>                                        │
│    - Create PR in submodule repo                                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. CLEANUP (After submodule PR merges)                                      │
│    - Update submodule pointer: git submodule update --remote <submodule>    │
│    - Delete patch: rm patches/<submodule>.patch                             │
│    - Commit to ap-base                                                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Creating Patches

### 1. Start with clean submodules

Always start from a clean slate:

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

Create the patches directory if it doesn't exist:

```bash
mkdir -p patches
```

For modified files only:
```bash
git diff > ../patches/<submodule>.patch
```

For new files (or both new and modified):
```bash
git add -A
git diff --cached > ../patches/<submodule>.patch
git reset HEAD
```

### 4. Reset the submodule

```bash
git checkout .
git clean -fd
cd ..
```

Or reset all submodules:

```bash
make deinit
make init
```

### 5. Verify the patch applies

```bash
make apply-patches
```

## Applying Patches

### Apply all patches

```bash
make apply-patches
```

This will:
1. Initialize submodules if needed
2. For each `patches/<submodule>.patch` file:
   - Apply the patch to the submodule

### Check which patches exist

```bash
make status
```

## Pushing to Submodule Remotes

After applying patches, push them to your fork:

```bash
make push-patches REMOTE=origin BRANCH=my-feature
```

This will:
1. For each submodule with an applied patch:
   - Create a branch named `BRANCH`
   - Commit the changes
   - Push to `REMOTE`

**Note**: You'll need to have your fork configured as a remote in each submodule, or use the upstream remote if you have push access.

## Cleaning Up After Merge

After the submodule PR is merged upstream:

### 1. Update the submodule pointer

```bash
cd <submodule>
git fetch origin
git checkout main
git pull
cd ..
git add <submodule>
```

### 2. Delete the patch

```bash
rm patches/<submodule>.patch
```

If no patches remain:
```bash
rmdir patches  # optional
```

### 3. Commit the cleanup

```bash
git add -A
git commit -m "Update <submodule> after upstream merge, remove patch"
```

## CI/Validation Behavior

When `make test`, `make lint`, `make validate`, etc. run:

1. Submodules are initialized
2. If `patches/` directory exists with `.patch` files, they are applied
3. Validation runs against the patched submodules

This ensures patches are validated before being applied to submodules.

## What If a Patch Fails to Apply?

If a patch fails, the upstream submodule has likely changed since the patch was created.

**Solution**: Regenerate the patch against the new upstream:

```bash
make deinit
make init
cd <submodule>
# Re-apply your changes manually or from the old patch
# Create new patch
git add -A
git diff --cached > ../patches/<submodule>.patch
git reset HEAD
cd ..
```

## FAQ

### Can I have multiple patches for the same submodule?

No. The flat structure allows only one patch per submodule. If you need multiple independent changes:
1. Complete and merge the first change
2. Then start the second change

This keeps the workflow simple and avoids patch conflicts.

### Should patches be on the main branch?

Ideally, no. Patches represent in-flight work. The cleanest workflow:
- Feature branch: contains patches
- Main branch: patches deleted after submodule merges

However, if patches need to persist briefly on main (e.g., waiting for submodule PR review), that's acceptable.

### What if upstream changes while my patch is pending?

Your patch may fail to apply. This is correct behavior - it forces you to reconcile your changes with upstream. Regenerate the patch against the new upstream.

### How do I handle coordinated changes across multiple submodules?

Create a patch for each submodule. They can all be in `patches/` at the same time:

```
patches/
├── ap-common.patch
├── ap-cull-lights.patch
└── ap-fits-headers.patch
```

Apply and push them together, then clean up each as their respective PRs merge.

## Quick Reference

```bash
# Setup
make deinit && make init

# Create patch (from submodule directory)
git add -A && git diff --cached > ../patches/<submodule>.patch && git reset HEAD

# Verify patches apply
make deinit && make init && make apply-patches

# Run validation with patches
make validate

# Push patches to forks
make push-patches REMOTE=origin BRANCH=my-feature

# Check status
make status

# Cleanup after merge
rm patches/<submodule>.patch
git submodule update --remote <submodule>
git add -A && git commit -m "Cleanup after merge"
```
