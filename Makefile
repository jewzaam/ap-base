# ap-base Makefile
# Workflow for managing patches across submodules

.PHONY: init deinit apply-patches apply-patch-% push-patches push-patch-% clean-patches status help
.PHONY: test lint format coverage typecheck validate
.PHONY: test-% lint-% format-% coverage-% typecheck-%

SUBMODULES := ap-common ap-cull-lights ap-empty-directory ap-fits-headers ap-master-calibration ap-move-calibration ap-move-lights ap-move-lights-to-data

# Variables for push-patches
REMOTE ?= origin
BRANCH ?=

help:
	@echo "ap-base patch management and validation"
	@echo ""
	@echo "Validation targets (all submodules):"
	@echo "  validate       - Run all validation checks (test, lint, format, typecheck)"
	@echo "  test           - Run tests in all submodules"
	@echo "  lint           - Run linter in all submodules"
	@echo "  format         - Run format check in all submodules"
	@echo "  coverage       - Run coverage in all submodules"
	@echo "  typecheck      - Run type check in all submodules"
	@echo ""
	@echo "Per-submodule validation (for parallel CI):"
	@echo "  test-<submodule>      - Run tests in specific submodule"
	@echo "  lint-<submodule>      - Run linter in specific submodule"
	@echo "  format-<submodule>    - Run format check in specific submodule"
	@echo "  coverage-<submodule>  - Run coverage in specific submodule"
	@echo "  typecheck-<submodule> - Run type check in specific submodule"
	@echo ""
	@echo "Submodule management:"
	@echo "  init           - Initialize and update all submodules"
	@echo "  deinit         - Deinitialize submodules and clear cache (clean slate)"
	@echo "  status         - Show patch status"
	@echo ""
	@echo "Patch management:"
	@echo "  apply-patches          - Apply all patches (idempotent)"
	@echo "  apply-patch-<submodule> - Apply patch to specific submodule"
	@echo "  push-patches           - Commit and push patches to submodule remotes"
	@echo "  push-patch-<submodule> - Push specific submodule"
	@echo "  clean-patches          - Reset all submodules to clean state"
	@echo ""
	@echo "Variables:"
	@echo "  REMOTE         - Remote to push to (default: origin)"
	@echo "  BRANCH         - Branch name to create (required for push)"
	@echo ""
	@echo "Examples:"
	@echo "  make test-ap-common                    # Test single submodule"
	@echo "  make apply-patch-ap-common             # Apply patch to single submodule"
	@echo "  make push-patches BRANCH=my-feature    # Push all patches to forks"
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

# =============================================================================
# Patch management
# =============================================================================

# Apply patch to a specific submodule (idempotent)
apply-patch-%: init
	@sub=$*; \
	if [ ! -f "patches/$$sub.patch" ]; then \
		echo "No patch for $$sub"; \
	elif cd $$sub && git apply --check ../patches/$$sub.patch 2>/dev/null; then \
		echo "Applying patches/$$sub.patch..."; \
		git apply ../patches/$$sub.patch; \
		cd ..; \
	else \
		echo "Patch for $$sub already applied or conflicts (skipping)"; \
		cd ..; \
	fi

# Apply all patches (idempotent)
apply-patches: init
	@echo "Applying patches..."
	@if [ -d "patches" ]; then \
		found=0; \
		for sub in $(SUBMODULES); do \
			if [ -f "patches/$$sub.patch" ]; then \
				found=1; \
				if cd $$sub && git apply --check ../patches/$$sub.patch 2>/dev/null; then \
					echo "Applying patches/$$sub.patch..."; \
					git apply ../patches/$$sub.patch; \
					cd ..; \
				else \
					echo "Patch for $$sub already applied or conflicts (skipping)"; \
					cd ..; \
				fi; \
			fi; \
		done; \
		if [ $$found -eq 0 ]; then \
			echo "No patches to apply."; \
		fi; \
	else \
		echo "No patches directory."; \
	fi

# Push patch for a specific submodule
push-patch-%:
	@if [ -z "$(BRANCH)" ]; then \
		echo "ERROR: BRANCH is required. Usage: make push-patch-<sub> BRANCH=<name>"; \
		exit 1; \
	fi
	@sub=$*; \
	if [ ! -f "patches/$$sub.patch" ]; then \
		echo "No patch for $$sub"; \
	else \
		echo "Pushing $$sub to $(REMOTE)/$(BRANCH)..."; \
		cd $$sub && \
		git checkout -b $(BRANCH) 2>/dev/null || git checkout $(BRANCH) && \
		git add -A && \
		git commit -m "Apply patch from ap-base" && \
		git push -u $(REMOTE) $(BRANCH); \
	fi

# Push all patches
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
# Per-submodule validation targets (for parallel CI)
# =============================================================================

test-%: apply-patch-%
	@sub=$*; \
	echo "=== Testing $$sub ==="; \
	$(MAKE) -C $$sub test

lint-%: apply-patch-%
	@sub=$*; \
	echo "=== Linting $$sub ==="; \
	$(MAKE) -C $$sub lint

format-%: apply-patch-%
	@sub=$*; \
	echo "=== Formatting $$sub ==="; \
	$(MAKE) -C $$sub format

coverage-%: apply-patch-%
	@sub=$*; \
	echo "=== Coverage $$sub ==="; \
	$(MAKE) -C $$sub coverage

typecheck-%: apply-patch-%
	@sub=$*; \
	echo "=== Type checking $$sub ==="; \
	$(MAKE) -C $$sub typecheck

# =============================================================================
# Aggregate validation targets (all submodules, sequential)
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
