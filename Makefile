# ap-base Makefile
# Submodule management and documentation checks

.PHONY: init deinit install-dev links markdown-lint submodule-links check help
.DEFAULT_GOAL := check

PYTHON := python
SUBMODULES := $(shell git submodule status | awk '{print $$2}' | xargs)

help:
	@echo "ap-base submodule management"
	@echo ""
	@echo "Targets:"
	@echo "  init           - Initialize and update all submodules"
	@echo "  deinit         - Deinitialize submodules and clear cache (clean slate)"
	@echo "  install-dev    - Install dev dependencies for checks"
	@echo "  check          - Run all checks (links + markdown-lint + submodule-links)"
	@echo "  links          - Validate markdown links"
	@echo "  markdown-lint  - Lint markdown files"
	@echo "  submodule-links - Check for dead links to submodule files"

init:
	git submodule update --init --recursive
	git submodule update --remote
	git submodule foreach 'git checkout main'

deinit:
	@echo "Deinitializing all submodules..."
	git submodule deinit -f --all
	@echo "Removing submodule cache..."
	rm -rf .git/modules/*
	@echo "Submodules fully cleaned. Run 'make init' to reinitialize."

install-dev:
	$(PYTHON) -m pip install -e ".[dev]"

check: links markdown-lint submodule-links

links: install-dev
	@echo "Checking markdown links..."
	$(PYTHON) -m linkcheck --no-status --no-warnings --check-extern --ignore-url="ap-.*" *.md docs/*.md docs/tools/*.md standards/*.md .claude/skills/*.md

markdown-lint: install-dev
	@echo "Linting markdown files..."
	$(PYTHON) -m pymarkdown --disable-rules MD013,MD024,MD031,MD036 scan .

submodule-links:
	@echo "Checking for dead links to submodule files..."
	$(PYTHON) scripts/check_submodule_links.py
