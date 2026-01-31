# ap-base Makefile
# Workflow for managing patches across submodules

.PHONY: init deinit apply-patches apply-all-patches apply-patch-% push-patches push-patch-% clean-patches status help
.PHONY: test lint format coverage typecheck validate

SUBMODULES := ap-common ap-cull-lights ap-empty-directory ap-fits-headers ap-master-calibration ap-move-calibration ap-move-lights ap-move-lights-to-data

# BRANCH must be set when applying patches, e.g.: make apply-patches BRANCH=readme-fixes-20260130
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
	@echo "  status         - Show patch status for each submodule"
	@echo ""
	@echo "Patch management:"
	@echo "  apply-all-patches - Apply patches from all branch directories"
	@echo "  apply-patches     - Apply all patches for BRANCH and create branches"
	@echo "  push-patches      - Push all branches with applied patches"
	@echo "  clean-patches     - Reset all submodules to main branch"
	@echo ""
	@echo "Individual targets:"
	@echo "  apply-patch-<submodule>  - Apply patch to specific submodule"
	@echo "  push-patch-<submodule>   - Push specific submodule branch"
	@echo ""
	@echo "Required variables:"
	@echo "  BRANCH         - Branch name for patches (e.g., readme-fixes-20260130)"
	@echo ""
	@echo "Example workflow:"
	@echo "  make validate                                  # Run all checks"
	@echo "  make deinit                                    # Clean slate"
	@echo "  make init                                      # Fresh submodules"
	@echo "  make apply-patches BRANCH=readme-fixes-20260130"
	@echo "  make push-patches BRANCH=readme-fixes-20260130"
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
	@echo "Patch directories:"
	@if [ -d "patches" ]; then \
		for dir in patches/*/; do \
			if [ -d "$$dir" ]; then \
				branch=$$(basename "$$dir"); \
				count=$$(ls -1 "$$dir"*.patch 2>/dev/null | wc -l); \
				echo "  $$branch: $$count patches"; \
			fi; \
		done; \
	else \
		echo "  No patches directory"; \
	fi
	@echo ""
	@if [ -n "$(BRANCH)" ]; then \
		echo "Patches for BRANCH=$(BRANCH):"; \
		if [ -d "patches/$(BRANCH)" ]; then \
			for sub in $(SUBMODULES); do \
				if [ -f "patches/$(BRANCH)/$$sub.patch" ]; then \
					lines=$$(wc -l < "patches/$(BRANCH)/$$sub.patch"); \
					echo "  $$sub: patch exists ($$lines lines)"; \
				else \
					echo "  $$sub: no patch"; \
				fi; \
			done; \
		else \
			echo "  Directory patches/$(BRANCH) does not exist"; \
		fi; \
	else \
		echo "Set BRANCH=<name> to see patches for a specific branch"; \
	fi

apply-all-patches: init
	@echo "Applying patches from all branch directories..."
	@if [ -d "patches" ]; then \
		for dir in patches/*/; do \
			if [ -d "$$dir" ]; then \
				branch=$$(basename "$$dir"); \
				echo ""; \
				echo "=== Applying patches for $$branch ==="; \
				for sub in $(SUBMODULES); do \
					if [ -f "patches/$$branch/$$sub.patch" ]; then \
						echo "Applying $$branch patch to $$sub..."; \
						cd $$sub && \
						git apply ../patches/$$branch/$$sub.patch && \
						cd ..; \
					fi; \
				done; \
			fi; \
		done; \
	else \
		echo "No patches directory found."; \
	fi
	@echo ""
	@echo "All patches applied."

apply-patches: init
	@if [ -z "$(BRANCH)" ]; then \
		echo "ERROR: BRANCH is required. Usage: make apply-patches BRANCH=<name>"; \
		exit 1; \
	fi
	@if [ ! -d "patches/$(BRANCH)" ]; then \
		echo "ERROR: patches/$(BRANCH) does not exist"; \
		exit 1; \
	fi
	@for sub in $(SUBMODULES); do \
		if [ -f "patches/$(BRANCH)/$$sub.patch" ]; then \
			echo "Applying patch to $$sub..."; \
			$(MAKE) apply-patch-$$sub BRANCH=$(BRANCH); \
		fi; \
	done

apply-patch-%:
	@if [ -z "$(BRANCH)" ]; then \
		echo "ERROR: BRANCH is required. Usage: make apply-patch-<sub> BRANCH=<name>"; \
		exit 1; \
	fi
	@sub=$*; \
	if [ ! -f "patches/$(BRANCH)/$$sub.patch" ]; then \
		echo "No patch for $$sub in patches/$(BRANCH)"; \
		exit 0; \
	fi; \
	cd $$sub && \
	git checkout main && \
	git pull origin main && \
	git checkout -b $(BRANCH) 2>/dev/null || git checkout $(BRANCH) && \
	git apply ../patches/$(BRANCH)/$$sub.patch && \
	git add -A && \
	git commit -m "Apply $(BRANCH) from ap-base" || echo "Nothing to commit for $$sub"

push-patches:
	@if [ -z "$(BRANCH)" ]; then \
		echo "ERROR: BRANCH is required. Usage: make push-patches BRANCH=<name>"; \
		exit 1; \
	fi
	@for sub in $(SUBMODULES); do \
		if [ -f "patches/$(BRANCH)/$$sub.patch" ]; then \
			echo "Pushing $$sub..."; \
			$(MAKE) push-patch-$$sub BRANCH=$(BRANCH); \
		fi; \
	done

push-patch-%:
	@if [ -z "$(BRANCH)" ]; then \
		echo "ERROR: BRANCH is required. Usage: make push-patch-<sub> BRANCH=<name>"; \
		exit 1; \
	fi
	@sub=$*; \
	cd $$sub && \
	git push -u origin $(BRANCH)

clean-patches:
	@for sub in $(SUBMODULES); do \
		echo "Resetting $$sub to main..."; \
		cd $$sub && git checkout main && git clean -fd && cd ..; \
	done

# =============================================================================
# Validation targets - run make targets across all submodules
# =============================================================================

test: apply-all-patches
	@echo "Running tests in all submodules..."
	@for sub in $(SUBMODULES); do \
		echo ""; \
		echo "=== Testing $$sub ==="; \
		$(MAKE) -C $$sub test || exit 1; \
	done
	@echo ""
	@echo "All tests passed."

lint: apply-all-patches
	@echo "Running linter in all submodules..."
	@for sub in $(SUBMODULES); do \
		echo ""; \
		echo "=== Linting $$sub ==="; \
		$(MAKE) -C $$sub lint || exit 1; \
	done
	@echo ""
	@echo "All lint checks passed."

format: apply-all-patches
	@echo "Checking format in all submodules..."
	@for sub in $(SUBMODULES); do \
		echo ""; \
		echo "=== Formatting $$sub ==="; \
		$(MAKE) -C $$sub format || exit 1; \
	done
	@echo ""
	@echo "All format checks passed."

coverage: apply-all-patches
	@echo "Running coverage in all submodules..."
	@for sub in $(SUBMODULES); do \
		echo ""; \
		echo "=== Coverage $$sub ==="; \
		$(MAKE) -C $$sub coverage || exit 1; \
	done
	@echo ""
	@echo "All coverage checks passed."

typecheck: apply-all-patches
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
