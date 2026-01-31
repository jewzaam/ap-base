#!/bin/bash
# publish-issues.sh - Create GitHub issues for ap-* project standards compliance
#
# Prerequisites:
#   - A GitHub Personal Access Token with 'repo' scope
#   - Set the GITHUB_TOKEN environment variable before running
#
# Usage:
#   export GITHUB_TOKEN="your_token_here"
#   ./publish-issues.sh [--dry-run] [--repo REPO_NAME]
#
# Options:
#   --dry-run       Print what would be created without actually creating issues
#   --repo NAME     Only create issues for the specified repo (e.g., ap-common)

set -euo pipefail

# Configuration
GITHUB_OWNER="jewzaam"
API_BASE="https://api.github.com"

# Parse arguments
DRY_RUN=false
FILTER_REPO=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --repo)
            FILTER_REPO="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check for GitHub token
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    echo "Error: GITHUB_TOKEN environment variable is not set."
    echo "Please set it with: export GITHUB_TOKEN='your_token_here'"
    exit 1
fi

# Function to check if issue already exists
issue_exists() {
    local repo="$1"
    local title="$2"

    # URL encode the title for search
    local encoded_title
    encoded_title=$(echo "$title" | sed 's/ /%20/g' | sed 's/:/%3A/g')

    # Search for open issues with matching title
    local response
    response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "${API_BASE}/repos/${GITHUB_OWNER}/${repo}/issues?state=open&per_page=100")

    # Check if title exists in response
    if echo "$response" | grep -q "\"title\": \"${title}\""; then
        return 0  # Issue exists
    fi
    return 1  # Issue does not exist
}

# Function to create an issue
create_issue() {
    local repo="$1"
    local title="$2"
    local body="$3"

    if [[ -n "$FILTER_REPO" && "$repo" != "$FILTER_REPO" ]]; then
        return 0
    fi

    echo ""
    echo "=========================================="
    echo "Repo: $repo"
    echo "Title: $title"
    echo "=========================================="

    # Check for duplicates
    if issue_exists "$repo" "$title"; then
        echo "⚠️  SKIPPED: Issue already exists"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "📋 DRY RUN: Would create issue"
        echo "Body preview:"
        echo "$body" | head -10
        echo "..."
        return 0
    fi

    # Create the issue
    local response
    response=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "${API_BASE}/repos/${GITHUB_OWNER}/${repo}/issues" \
        -d "$(jq -n --arg title "$title" --arg body "$body" '{title: $title, body: $body}')")

    # Check response
    if echo "$response" | grep -q '"number":'; then
        local issue_number
        issue_number=$(echo "$response" | jq -r '.number')
        echo "✅ Created issue #${issue_number}"
        echo "   URL: https://github.com/${GITHUB_OWNER}/${repo}/issues/${issue_number}"
    else
        echo "❌ Failed to create issue"
        echo "Response: $response"
        return 1
    fi
}

echo "=================================================="
echo "GitHub Issue Publisher for ap-* Projects"
echo "=================================================="
echo "Owner: $GITHUB_OWNER"
echo "Dry Run: $DRY_RUN"
[[ -n "$FILTER_REPO" ]] && echo "Filtering to repo: $FILTER_REPO"
echo ""

# ============================================================================
# ap-common Issues
# ============================================================================

create_issue "ap-common" \
    "Add mypy and typecheck target for type checking support" \
    "## Summary
The project is missing type checking infrastructure that is required by the [ap-base standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md).

## What's Missing

### 1. Makefile typecheck target
The Makefile does not include a \`typecheck\` target. Per the standards, this target should be defined as:
\`\`\`makefile
typecheck: install-dev
	\$(PYTHON) -m mypy ap_common
\`\`\`

### 2. Default target missing typecheck
The current \`default\` target is:
\`\`\`makefile
default: format lint test coverage
\`\`\`
It should include \`typecheck\`:
\`\`\`makefile
default: format lint typecheck test coverage
\`\`\`

### 3. mypy missing from dev dependencies
\`pyproject.toml\` does not include mypy in the dev dependencies. Add it to \`[project.optional-dependencies]\`:
\`\`\`toml
dev = [
    \"pytest>=7.0\",
    \"pytest-cov>=4.0\",
    \"black>=23.0\",
    \"flake8>=6.0\",
    \"mypy>=1.0\",
]
\`\`\`

## Reference
- [Makefile Standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md)
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Add \`typecheck\` target to Makefile
- [ ] Add \`typecheck\` to default target
- [ ] Add mypy to dev dependencies in pyproject.toml
- [ ] \`make typecheck\` passes without errors"

# ============================================================================
# ap-cull-lights Issues
# ============================================================================

create_issue "ap-cull-lights" \
    "Add LICENSE file" \
    "## Summary
The repository is missing a LICENSE file, which is a required file per the [ap-base standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md).

## What's Missing
A LICENSE file needs to be added to the root of the repository.

## Recommendation
Use the same license as other ap-* projects. Based on ap-common, this should be the Apache License 2.0.

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Add LICENSE file to repository root
- [ ] Use Apache License 2.0 (or consistent with other ap-* projects)"

create_issue "ap-cull-lights" \
    "Add README badges per standards" \
    "## Summary
The README.md is missing the standard badges required by the [ap-base README format standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md).

## What's Missing
Six standard badges should appear at the top of the README after the title:

\`\`\`markdown
[![Test](https://github.com/jewzaam/ap-cull-lights/workflows/Test/badge.svg)](https://github.com/jewzaam/ap-cull-lights/actions/workflows/test.yml)
[![Coverage](https://github.com/jewzaam/ap-cull-lights/workflows/Coverage%20Check/badge.svg)](https://github.com/jewzaam/ap-cull-lights/actions/workflows/coverage.yml)
[![Lint](https://github.com/jewzaam/ap-cull-lights/workflows/Lint/badge.svg)](https://github.com/jewzaam/ap-cull-lights/actions/workflows/lint.yml)
[![Format](https://github.com/jewzaam/ap-cull-lights/workflows/Format%20Check/badge.svg)](https://github.com/jewzaam/ap-cull-lights/actions/workflows/format.yml)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
\`\`\`

## Reference
- [README Format Standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md)

## Acceptance Criteria
- [ ] Add all 6 badges to README.md after the title"

create_issue "ap-cull-lights" \
    "Add mypy and typecheck target for type checking support" \
    "## Summary
The project is missing type checking infrastructure that is required by the [ap-base standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md).

## What's Missing

### 1. Makefile typecheck target
The Makefile does not include a \`typecheck\` target.

### 2. Default target missing typecheck
The \`default\` target should include \`typecheck\`:
\`\`\`makefile
default: format lint typecheck test coverage
\`\`\`

### 3. mypy missing from dev dependencies
Add mypy to \`[project.optional-dependencies]\` in pyproject.toml:
\`\`\`toml
dev = [
    ...
    \"mypy>=1.0\",
]
\`\`\`

## Reference
- [Makefile Standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md)

## Acceptance Criteria
- [ ] Add \`typecheck\` target to Makefile
- [ ] Add \`typecheck\` to default target
- [ ] Add mypy to dev dependencies
- [ ] \`make typecheck\` passes"

create_issue "ap-cull-lights" \
    "Update requires-python to >=3.10" \
    "## Summary
The \`pyproject.toml\` specifies \`requires-python = \">=3.8\"\` but the [ap-base standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md) require Python 3.10+.

## Current Value
\`\`\`toml
requires-python = \">=3.8\"
\`\`\`

## Required Value
\`\`\`toml
requires-python = \">=3.10\"
\`\`\`

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Update \`requires-python\` to \`>=3.10\` in pyproject.toml"

create_issue "ap-cull-lights" \
    "Add __main__.py for CLI entry point" \
    "## Summary
The package is missing \`__main__.py\` which is required for CLI entry point support via \`python -m ap_cull_lights\`.

## What's Missing
Create \`ap_cull_lights/__main__.py\` as the entry point for the module.

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)
- [CLI Standards](https://github.com/thelenorith/ap-base/blob/main/standards/cli.md)

## Acceptance Criteria
- [ ] Add \`ap_cull_lights/__main__.py\`
- [ ] \`python -m ap_cull_lights\` works correctly"

create_issue "ap-cull-lights" \
    "Consider renaming to ap-cull-light (singular noun)" \
    "## Summary
Per the [ap-base naming conventions](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md), project names should use **singular nouns**.

## Current Name
\`ap-cull-lights\` (plural)

## Recommended Name
\`ap-cull-light\` (singular)

## Naming Pattern
The standard pattern is:
\`\`\`
ap-{verb}-{qualifier?}-{noun}-to-{destination?}
\`\`\`
Where nouns are always singular: \`light\` not \`lights\`, \`header\` not \`headers\`.

## Reference
- [Naming Standards](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md)

## Notes
This is a significant change that would require updating:
- Repository name
- Package directory name
- All imports
- pyproject.toml
- Makefile references
- GitHub workflow references

Consider whether this rename is worth the effort given existing usage."

# ============================================================================
# ap-empty-directory Issues
# ============================================================================

create_issue "ap-empty-directory" \
    "Add mypy and typecheck target for type checking support" \
    "## Summary
The project is missing proper type checking infrastructure. While there is a \`typecheck\` target in the Makefile, it is not included in the \`default\` target, and mypy is not in the dev dependencies.

## What's Missing

### 1. Default target missing typecheck
Current:
\`\`\`makefile
default: format lint test coverage
\`\`\`
Should be:
\`\`\`makefile
default: format lint typecheck test coverage
\`\`\`

### 2. mypy missing from dev dependencies
Add to pyproject.toml:
\`\`\`toml
dev = [
    ...
    \"mypy>=1.0\",
]
\`\`\`

## Reference
- [Makefile Standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md)

## Acceptance Criteria
- [ ] Add \`typecheck\` to default target
- [ ] Add mypy to dev dependencies
- [ ] \`make typecheck\` passes"

create_issue "ap-empty-directory" \
    "Update README badge URLs to standard format" \
    "## Summary
The README badges use a non-standard URL format that differs from the [ap-base README standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md).

## Current Format
\`\`\`
https://github.com/jewzaam/ap-empty-directory/actions/workflows/test.yml/badge.svg
\`\`\`

## Standard Format
\`\`\`
https://github.com/jewzaam/ap-empty-directory/workflows/Test/badge.svg
\`\`\`

## Reference
- [README Format Standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md)

## Acceptance Criteria
- [ ] Update all badge URLs to use the standard format"

create_issue "ap-empty-directory" \
    "Review naming convention compliance" \
    "## Summary
The project name \`ap-empty-directory\` doesn't clearly follow the standard naming pattern from [ap-base naming conventions](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md).

## Naming Pattern
\`\`\`
ap-{verb}-{qualifier?}-{noun}-to-{destination?}
\`\`\`

## Analysis
- \`empty\` is a verb ✓
- \`directory\` is a noun ✓

However, the tool empties directories (removes empty ones), so the name could be interpreted as either:
1. A command to empty a directory, or
2. A tool that deals with empty directories

## Suggested Alternative
Consider \`ap-delete-empty-directory\` to be more explicit about the action.

## Notes
This is a low-priority naming discussion. The current name may be acceptable given the context.

## Reference
- [Naming Standards](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md)"

# ============================================================================
# ap-fits-headers Issues
# ============================================================================

create_issue "ap-fits-headers" \
    "Add LICENSE file" \
    "## Summary
The repository is missing a LICENSE file, which is a required file per the [ap-base standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md).

## What's Missing
A LICENSE file needs to be added to the root of the repository.

## Recommendation
Use the same license as other ap-* projects (Apache License 2.0).

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Add LICENSE file to repository root"

create_issue "ap-fits-headers" \
    "Add README badges per standards" \
    "## Summary
The README.md is missing the standard badges required by the [ap-base README format standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md).

## What's Missing
Six standard badges should appear at the top of the README:

\`\`\`markdown
[![Test](https://github.com/jewzaam/ap-fits-headers/workflows/Test/badge.svg)](https://github.com/jewzaam/ap-fits-headers/actions/workflows/test.yml)
[![Coverage](https://github.com/jewzaam/ap-fits-headers/workflows/Coverage%20Check/badge.svg)](https://github.com/jewzaam/ap-fits-headers/actions/workflows/coverage.yml)
[![Lint](https://github.com/jewzaam/ap-fits-headers/workflows/Lint/badge.svg)](https://github.com/jewzaam/ap-fits-headers/actions/workflows/lint.yml)
[![Format](https://github.com/jewzaam/ap-fits-headers/workflows/Format%20Check/badge.svg)](https://github.com/jewzaam/ap-fits-headers/actions/workflows/format.yml)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
\`\`\`

## Reference
- [README Format Standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md)

## Acceptance Criteria
- [ ] Add all 6 badges to README.md"

create_issue "ap-fits-headers" \
    "Add mypy and typecheck target for type checking support" \
    "## Summary
The project is missing type checking infrastructure required by the [ap-base standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md).

## What's Missing
1. Makefile \`typecheck\` target
2. \`typecheck\` in default target
3. mypy in dev dependencies

## Reference
- [Makefile Standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md)

## Acceptance Criteria
- [ ] Add \`typecheck\` target to Makefile
- [ ] Add \`typecheck\` to default target
- [ ] Add mypy to dev dependencies
- [ ] \`make typecheck\` passes"

create_issue "ap-fits-headers" \
    "Update requires-python to >=3.10" \
    "## Summary
The \`pyproject.toml\` specifies \`requires-python = \">=3.8\"\` but the standards require Python 3.10+.

## Current Value
\`\`\`toml
requires-python = \">=3.8\"
\`\`\`

## Required Value
\`\`\`toml
requires-python = \">=3.10\"
\`\`\`

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Update \`requires-python\` to \`>=3.10\`"

create_issue "ap-fits-headers" \
    "Add __main__.py for CLI entry point" \
    "## Summary
The package is missing \`__main__.py\` required for CLI entry point support via \`python -m ap_fits_headers\`.

## What's Missing
Create \`ap_fits_headers/__main__.py\` as the entry point.

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Add \`ap_fits_headers/__main__.py\`
- [ ] \`python -m ap_fits_headers\` works correctly"

create_issue "ap-fits-headers" \
    "Consider renaming to ap-preserve-header" \
    "## Summary
Per the [ap-base naming conventions](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md), this project should follow the \`ap-{verb}-{noun}\` pattern.

## Current Name
\`ap-fits-headers\`

## Recommended Name
\`ap-preserve-header\`

## Rationale
- Starts with a verb (\`preserve\`)
- Uses singular noun (\`header\`)
- Describes the action (preserving path metadata into headers)

## Reference
- [Naming Standards](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md)
- [SUGGESTED_RENAMES.md](https://github.com/thelenorith/ap-base/blob/main/SUGGESTED_RENAMES.md)

## Notes
This is a significant rename. Consider the impact on existing users/scripts."

# ============================================================================
# ap-master-calibration Issues
# ============================================================================

create_issue "ap-master-calibration" \
    "Update README title to use project name" \
    "## Summary
The README title uses a prose description instead of the project name as required by [ap-base README standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md).

## Current Title
\`\`\`markdown
# Master Calibration Frame Automation
\`\`\`

## Required Title
\`\`\`markdown
# ap-master-calibration
\`\`\`

## Reference
The standard states: \"Use the package name as the title\" and \"Do not use prose titles like 'Light Frame Organization Tool'.\"

- [README Format Standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md)

## Acceptance Criteria
- [ ] Change README title to \`# ap-master-calibration\`"

create_issue "ap-master-calibration" \
    "Add README badges per standards" \
    "## Summary
The README.md is missing the standard badges required by the [ap-base README format standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md).

## What's Missing
Six standard badges should appear at the top of the README:

\`\`\`markdown
[![Test](https://github.com/jewzaam/ap-master-calibration/workflows/Test/badge.svg)](https://github.com/jewzaam/ap-master-calibration/actions/workflows/test.yml)
[![Coverage](https://github.com/jewzaam/ap-master-calibration/workflows/Coverage%20Check/badge.svg)](https://github.com/jewzaam/ap-master-calibration/actions/workflows/coverage.yml)
[![Lint](https://github.com/jewzaam/ap-master-calibration/workflows/Lint/badge.svg)](https://github.com/jewzaam/ap-master-calibration/actions/workflows/lint.yml)
[![Format](https://github.com/jewzaam/ap-master-calibration/workflows/Format%20Check/badge.svg)](https://github.com/jewzaam/ap-master-calibration/actions/workflows/format.yml)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
\`\`\`

## Reference
- [README Format Standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md)

## Acceptance Criteria
- [ ] Add all 6 badges to README.md"

create_issue "ap-master-calibration" \
    "Add mypy and typecheck target for type checking support" \
    "## Summary
The project is missing type checking infrastructure required by the [ap-base standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md).

## What's Missing
1. Makefile \`typecheck\` target
2. \`typecheck\` in default target
3. mypy in dev dependencies

## Reference
- [Makefile Standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md)

## Acceptance Criteria
- [ ] Add \`typecheck\` target to Makefile
- [ ] Add \`typecheck\` to default target
- [ ] Add mypy to dev dependencies
- [ ] \`make typecheck\` passes"

create_issue "ap-master-calibration" \
    "Update requires-python to >=3.10" \
    "## Summary
The \`pyproject.toml\` specifies \`requires-python = \">=3.8\"\` but the standards require Python 3.10+.

## Current Value
\`\`\`toml
requires-python = \">=3.8\"
\`\`\`

## Required Value
\`\`\`toml
requires-python = \">=3.10\"
\`\`\`

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Update \`requires-python\` to \`>=3.10\`"

create_issue "ap-master-calibration" \
    "Consider renaming to ap-create-master" \
    "## Summary
Per the [ap-base naming conventions](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md), this project should follow the \`ap-{verb}-{noun}\` pattern.

## Current Name
\`ap-master-calibration\`

## Recommended Name
\`ap-create-master\`

## Rationale
- Starts with a verb (\`create\`)
- Uses singular noun (\`master\`)
- Describes the action (creating master calibration frames)

## Reference
- [Naming Standards](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md)
- [SUGGESTED_RENAMES.md](https://github.com/thelenorith/ap-base/blob/main/SUGGESTED_RENAMES.md)

## Notes
This is a significant rename. Consider the impact on existing users/scripts."

# ============================================================================
# ap-move-calibration Issues
# ============================================================================

create_issue "ap-move-calibration" \
    "Add README.md file" \
    "## Summary
The repository is **missing README.md**, which is a critical required file per the [ap-base standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md).

Note: There is a \`GUIDANCE.md\` file but no \`README.md\`.

## What's Needed
Create a README.md following the [README format standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md):

1. Title (project name)
2. Badges (6 standard badges)
3. Brief description
4. Overview
5. Installation
6. Usage

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)
- [README Format Standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md)

## Acceptance Criteria
- [ ] Add README.md with all required sections
- [ ] Include all 6 standard badges"

create_issue "ap-move-calibration" \
    "Add MANIFEST.in file" \
    "## Summary
The repository is missing \`MANIFEST.in\`, which is a required file per the [ap-base standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md).

## What's Needed
Create \`MANIFEST.in\`:
\`\`\`
include LICENSE
include README.md
recursive-include ap_move_calibration *.py
\`\`\`

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Add MANIFEST.in file"

create_issue "ap-move-calibration" \
    "Add tests/__init__.py" \
    "## Summary
The \`tests/\` directory exists but is missing \`__init__.py\`, which is required per the [ap-base testing standards](https://github.com/thelenorith/ap-base/blob/main/standards/testing.md).

## What's Missing
Create \`tests/__init__.py\` (can be empty).

## Reference
- [Testing Standards](https://github.com/thelenorith/ap-base/blob/main/standards/testing.md)

## Acceptance Criteria
- [ ] Add \`tests/__init__.py\`"

create_issue "ap-move-calibration" \
    "Add mypy and typecheck target for type checking support" \
    "## Summary
The project is missing type checking infrastructure required by the [ap-base standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md).

## What's Missing
1. Makefile \`typecheck\` target
2. \`typecheck\` in default target
3. mypy in dev dependencies

## Reference
- [Makefile Standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md)

## Acceptance Criteria
- [ ] Add \`typecheck\` target to Makefile
- [ ] Add \`typecheck\` to default target
- [ ] Add mypy to dev dependencies
- [ ] \`make typecheck\` passes"

create_issue "ap-move-calibration" \
    "Update requires-python to >=3.10" \
    "## Summary
The \`pyproject.toml\` specifies \`requires-python = \">=3.8\"\` but the standards require Python 3.10+.

## Current Value
\`\`\`toml
requires-python = \">=3.8\"
\`\`\`

## Required Value
\`\`\`toml
requires-python = \">=3.10\"
\`\`\`

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Update \`requires-python\` to \`>=3.10\`"

create_issue "ap-move-calibration" \
    "Add __main__.py for CLI entry point" \
    "## Summary
The package is missing \`__main__.py\` required for CLI entry point support via \`python -m ap_move_calibration\`.

## What's Missing
Create \`ap_move_calibration/__main__.py\` as the entry point.

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Add \`ap_move_calibration/__main__.py\`
- [ ] \`python -m ap_move_calibration\` works correctly"

create_issue "ap-move-calibration" \
    "Consider renaming to ap-move-master-to-library" \
    "## Summary
Per the [ap-base naming conventions](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md), this project should follow the \`ap-{verb}-{noun}-to-{destination}\` pattern for tools that move data.

## Current Name
\`ap-move-calibration\`

## Recommended Name
\`ap-move-master-to-library\`

## Rationale
- Uses \`master\` noun (consistent with terminology)
- Includes destination (\`to-library\`)
- Follows pattern: \`ap-{verb}-{noun}-to-{dest}\`

## Reference
- [Naming Standards](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md)
- [SUGGESTED_RENAMES.md](https://github.com/thelenorith/ap-base/blob/main/SUGGESTED_RENAMES.md)

## Notes
This is a significant rename. Consider the impact on existing users/scripts."

# ============================================================================
# ap-move-lights Issues
# ============================================================================

create_issue "ap-move-lights" \
    "Fix MANIFEST.in package name (critical)" \
    "## Summary
**CRITICAL BUG**: The MANIFEST.in references the wrong package name.

## Current (Incorrect)
\`\`\`
recursive-include ap_copy_lights *.py
\`\`\`

## Required (Correct)
\`\`\`
recursive-include ap_move_lights *.py
\`\`\`

This will cause \`sdist\` builds to exclude the actual package code.

## Acceptance Criteria
- [ ] Fix package name in MANIFEST.in to \`ap_move_lights\`"

create_issue "ap-move-lights" \
    "Add README badges per standards" \
    "## Summary
The README.md is missing the standard badges required by the [ap-base README format standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md).

## What's Missing
Six standard badges should appear at the top of the README:

\`\`\`markdown
[![Test](https://github.com/jewzaam/ap-move-lights/workflows/Test/badge.svg)](https://github.com/jewzaam/ap-move-lights/actions/workflows/test.yml)
[![Coverage](https://github.com/jewzaam/ap-move-lights/workflows/Coverage%20Check/badge.svg)](https://github.com/jewzaam/ap-move-lights/actions/workflows/coverage.yml)
[![Lint](https://github.com/jewzaam/ap-move-lights/workflows/Lint/badge.svg)](https://github.com/jewzaam/ap-move-lights/actions/workflows/lint.yml)
[![Format](https://github.com/jewzaam/ap-move-lights/workflows/Format%20Check/badge.svg)](https://github.com/jewzaam/ap-move-lights/actions/workflows/format.yml)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
\`\`\`

## Reference
- [README Format Standards](https://github.com/thelenorith/ap-base/blob/main/standards/readme-format.md)

## Acceptance Criteria
- [ ] Add all 6 badges to README.md"

create_issue "ap-move-lights" \
    "Add mypy and typecheck target for type checking support" \
    "## Summary
The project is missing type checking infrastructure required by the [ap-base standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md).

## What's Missing
1. Makefile \`typecheck\` target
2. \`typecheck\` in default target
3. mypy in dev dependencies

## Reference
- [Makefile Standards](https://github.com/thelenorith/ap-base/blob/main/standards/makefile.md)

## Acceptance Criteria
- [ ] Add \`typecheck\` target to Makefile
- [ ] Add \`typecheck\` to default target
- [ ] Add mypy to dev dependencies
- [ ] \`make typecheck\` passes"

create_issue "ap-move-lights" \
    "Update requires-python to >=3.10" \
    "## Summary
The \`pyproject.toml\` specifies \`requires-python = \">=3.8\"\` but the standards require Python 3.10+.

## Current Value
\`\`\`toml
requires-python = \">=3.8\"
\`\`\`

## Required Value
\`\`\`toml
requires-python = \">=3.10\"
\`\`\`

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Update \`requires-python\` to \`>=3.10\`"

create_issue "ap-move-lights" \
    "Add __main__.py for CLI entry point" \
    "## Summary
The package is missing \`__main__.py\` required for CLI entry point support via \`python -m ap_move_lights\`.

## What's Missing
Create \`ap_move_lights/__main__.py\` as the entry point.

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Add \`ap_move_lights/__main__.py\`
- [ ] \`python -m ap_move_lights\` works correctly"

create_issue "ap-move-lights" \
    "Consider renaming to ap-move-raw-light-to-blink" \
    "## Summary
Per the [ap-base naming conventions](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md), this project should follow the full naming pattern including qualifier and destination.

## Current Name
\`ap-move-lights\`

## Recommended Name
\`ap-move-raw-light-to-blink\`

## Rationale
- Uses singular noun (\`light\`)
- Includes qualifier (\`raw\`) to indicate unprocessed frames
- Includes destination (\`to-blink\`) to indicate where frames go
- Follows pattern: \`ap-{verb}-{qualifier}-{noun}-to-{dest}\`

## Reference
- [Naming Standards](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md)
- [SUGGESTED_RENAMES.md](https://github.com/thelenorith/ap-base/blob/main/SUGGESTED_RENAMES.md)

## Notes
This is a significant rename. Consider the impact on existing users/scripts."

# ============================================================================
# ap-move-lights-to-data Issues
# (Limited issues - this repo is most compliant)
# ============================================================================

create_issue "ap-move-lights-to-data" \
    "Use singular noun in project name (ap-move-light-to-data)" \
    "## Summary
Per the [ap-base naming conventions](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md), project names should use **singular nouns**.

## Current Name
\`ap-move-lights-to-data\` (plural)

## Recommended Name
\`ap-move-light-to-data\` (singular)

## Reference
- [Naming Standards](https://github.com/thelenorith/ap-base/blob/main/standards/naming.md)

## Notes
This is a minor naming inconsistency. The project is otherwise well-compliant with standards."

create_issue "ap-move-lights-to-data" \
    "Remove upper bound from requires-python" \
    "## Summary
The \`pyproject.toml\` uses \`requires-python = \">=3.10,<3.15\"\` but the standard shows no upper bound.

## Current Value
\`\`\`toml
requires-python = \">=3.10,<3.15\"
\`\`\`

## Recommended Value
\`\`\`toml
requires-python = \">=3.10\"
\`\`\`

## Rationale
Upper bounds on Python versions can cause unnecessary breakage when new Python versions are released. The standard example does not include an upper bound.

## Reference
- [Project Structure Standards](https://github.com/thelenorith/ap-base/blob/main/standards/project-structure.md)

## Acceptance Criteria
- [ ] Remove \`<3.15\` constraint from requires-python"

create_issue "ap-move-lights-to-data" \
    "Update GitHub Actions to use setup-python@v5" \
    "## Summary
Some workflows may be using \`actions/setup-python@v4\` instead of the current \`@v5\` per [ap-base GitHub workflow standards](https://github.com/thelenorith/ap-base/blob/main/standards/github-workflows.md).

## Current
\`\`\`yaml
uses: actions/setup-python@v4
\`\`\`

## Required
\`\`\`yaml
uses: actions/setup-python@v5
\`\`\`

## Reference
- [GitHub Workflows Standards](https://github.com/thelenorith/ap-base/blob/main/standards/github-workflows.md)

## Acceptance Criteria
- [ ] Update all workflows to use \`actions/setup-python@v5\`"

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "=================================================="
echo "Issue creation complete!"
echo "=================================================="
echo ""
echo "Summary of issues by repo:"
echo "  - ap-common: 1 issue"
echo "  - ap-cull-lights: 6 issues"
echo "  - ap-empty-directory: 3 issues"
echo "  - ap-fits-headers: 6 issues"
echo "  - ap-master-calibration: 5 issues"
echo "  - ap-move-calibration: 7 issues"
echo "  - ap-move-lights: 6 issues"
echo "  - ap-move-lights-to-data: 3 issues"
echo ""
echo "Total: 37 issues"
