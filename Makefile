# ap-base Makefile
# Workflow for managing patches across submodules

.PHONY: init deinit apply-patches push-patches clean-patches status help
.PHONY: test lint format coverage typecheck validate

SUBMODULES := ap-common ap-cull-lights ap-empty-directory ap-fits-headers ap-master-calibration ap-move-calibration ap-move-lights ap-move-lights-to-data

# Variables for push-patches
REMOTE ?= origin
BRANCH ?=

help:
	@echo "ap-base patch management and validation"
	@echo ""
	@echo "Validation targets:"
	@echo "  validate       - Run all validation checks (test, lint, format, typecheck)"
	@echo "  test           - Run tests in all submodules"
	@echo "  lint           - Run linter in all submodules"
	@echo "  format         - Run format check in all submodules"
	@echo "  coverage       - Run coverage in all submodules"
	@echo "  typecheck      - Run type check in all submodules"
	@echo ""
	@echo "Submodule management:"
	@echo "  init           - Initialize and update all submodules"
	@echo "  deinit         - Deinitialize submodules and clear cache (clean slate)"
	@echo "  status         - Show patch status"
	@echo ""
	@echo "Patch management:"
	@echo "  apply-patches  - Apply all patches from patches/ directory"
	@echo "  push-patches   - Commit and push patches to submodule remotes"
	@echo "  clean-patches  - Reset all submodules to clean state"
	@echo ""
	@echo "Variables for push-patches:"
	@echo "  REMOTE         - Remote to push to (default: origin)"
	@echo "  BRANCH         - Branch name to create (required)"
	@echo ""
	@echo "Example workflow:"
	@echo "  make validate                              # Run all checks"
	@echo "  make apply-patches                         # Apply patches"
	@echo "  make push-patches BRANCH=my-feature        # Push to forks"
	@echo ""
	@echo "See PATCHING.md for detailed workflow documentation."

init:
	git submodule update --init --recursive

deinit:
	@echo "Deinitializing all submodules..."
	git submodule deinit -f --all
	@echo "Removing submodule cache..."
	rm -rf .git/modules/*
	@echo "Submodules fully cleaned. Run 'make init' to reinitialize."

status:
	@echo "Patches (patches/<submodule>.patch):"
	@if [ -d "patches" ]; then \
		found=0; \
		for sub in $(SUBMODULES); do \
			if [ -f "patches/$$sub.patch" ]; then \
				lines=$$(wc -l < "patches/$$sub.patch"); \
				echo "  $$sub.patch ($$lines lines)"; \
				found=1; \
			fi; \
		done; \
		if [ $$found -eq 0 ]; then \
			echo "  (no patches)"; \
		fi; \
	else \
		echo "  (no patches directory)"; \
	fi

apply-patches: init
	@echo "Applying patches..."
	@if [ -d "patches" ]; then \
		found=0; \
		for sub in $(SUBMODULES); do \
			if [ -f "patches/$$sub.patch" ]; then \
				echo "Applying patches/$$sub.patch..."; \
				cd $$sub && git apply ../patches/$$sub.patch && cd ..; \
				found=1; \
			fi; \
		done; \
		if [ $$found -eq 0 ]; then \
			echo "No patches to apply."; \
		else \
			echo ""; \
			echo "Patches applied successfully."; \
		fi; \
	else \
		echo "No patches directory."; \
	fi

push-patches:
	@if [ -z "$(BRANCH)" ]; then \
		echo "ERROR: BRANCH is required. Usage: make push-patches BRANCH=<name>"; \
		exit 1; \
	fi
	@echo "Pushing patches to $(REMOTE)/$(BRANCH)..."
	@if [ -d "patches" ]; then \
		for sub in $(SUBMODULES); do \
			if [ -f "patches/$$sub.patch" ]; then \
				echo ""; \
				echo "=== Pushing $$sub ==="; \
				cd $$sub && \
				git checkout -b $(BRANCH) 2>/dev/null || git checkout $(BRANCH) && \
				git add -A && \
				git commit -m "Apply patch from ap-base" && \
				git push -u $(REMOTE) $(BRANCH) && \
				cd ..; \
			fi; \
		done; \
	else \
		echo "No patches directory."; \
	fi

clean-patches:
	@echo "Resetting submodules to clean state..."
	@for sub in $(SUBMODULES); do \
		if [ -d "$$sub/.git" ] || [ -f "$$sub/.git" ]; then \
			echo "Resetting $$sub..."; \
			cd $$sub && git checkout . && git clean -fd && cd ..; \
		fi; \
	done
	@echo "Submodules reset."

# =============================================================================
# Validation targets - run make targets across all submodules
# =============================================================================

test: apply-patches
	@echo "Running tests in all submodules..."
	@for sub in $(SUBMODULES); do \
		echo ""; \
		echo "=== Testing $$sub ==="; \
		$(MAKE) -C $$sub test || exit 1; \
	done
	@echo ""
	@echo "All tests passed."

lint: apply-patches
	@echo "Running linter in all submodules..."
	@for sub in $(SUBMODULES); do \
		echo ""; \
		echo "=== Linting $$sub ==="; \
		$(MAKE) -C $$sub lint || exit 1; \
	done
	@echo ""
	@echo "All lint checks passed."

format: apply-patches
	@echo "Checking format in all submodules..."
	@for sub in $(SUBMODULES); do \
		echo ""; \
		echo "=== Formatting $$sub ==="; \
		$(MAKE) -C $$sub format || exit 1; \
	done
	@echo ""
	@echo "All format checks passed."

coverage: apply-patches
	@echo "Running coverage in all submodules..."
	@for sub in $(SUBMODULES); do \
		echo ""; \
		echo "=== Coverage $$sub ==="; \
		$(MAKE) -C $$sub coverage || exit 1; \
	done
	@echo ""
	@echo "All coverage checks passed."

typecheck: apply-patches
	@echo "Running type check in all submodules..."
	@for sub in $(SUBMODULES); do \
		echo ""; \
		echo "=== Type checking $$sub ==="; \
		$(MAKE) -C $$sub typecheck || exit 1; \
	done
	@echo ""
	@echo "All type checks passed."

validate: test lint format typecheck
	@echo ""
	@echo "=== All validation checks passed ==="
