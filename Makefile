# ap-base Makefile
# Workflow for managing patches across submodules

.PHONY: init apply-patches apply-patch-% push-patches push-patch-% clean-patches status help

SUBMODULES := ap-common ap-cull-lights ap-fits-headers ap-master-calibration ap-move-calibration ap-move-lights
BRANCH_PREFIX := consistency-fixes

help:
	@echo "ap-base patch management"
	@echo ""
	@echo "Targets:"
	@echo "  init           - Initialize and update all submodules"
	@echo "  status         - Show patch status for each submodule"
	@echo "  apply-patches  - Apply all patches and create branches (does not push)"
	@echo "  push-patches   - Push all branches with applied patches"
	@echo "  clean-patches  - Reset all submodules to main branch"
	@echo ""
	@echo "Individual targets:"
	@echo "  apply-patch-<submodule>  - Apply patch to specific submodule"
	@echo "  push-patch-<submodule>   - Push specific submodule branch"
	@echo ""
	@echo "Example:"
	@echo "  make apply-patches    # Apply all patches locally"
	@echo "  make push-patches     # Push all branches to origin"

init:
	git submodule update --init --recursive

status:
	@echo "Patch status:"
	@for sub in $(SUBMODULES); do \
		if [ -f "patches/$$sub.patch" ]; then \
			lines=$$(wc -l < "patches/$$sub.patch"); \
			echo "  $$sub: patch exists ($$lines lines)"; \
		else \
			echo "  $$sub: no patch"; \
		fi; \
	done

apply-patches: init
	@for sub in $(SUBMODULES); do \
		if [ -f "patches/$$sub.patch" ]; then \
			echo "Applying patch to $$sub..."; \
			$(MAKE) apply-patch-$$sub; \
		fi; \
	done

apply-patch-%:
	@sub=$*; \
	if [ ! -f "patches/$$sub.patch" ]; then \
		echo "No patch for $$sub"; \
		exit 0; \
	fi; \
	cd $$sub && \
	git checkout main && \
	git pull origin main && \
	git checkout -b $(BRANCH_PREFIX) 2>/dev/null || git checkout $(BRANCH_PREFIX) && \
	git apply ../patches/$$sub.patch && \
	git add -A && \
	git commit -m "Apply consistency fixes from ap-base" || echo "Nothing to commit for $$sub"

push-patches:
	@for sub in $(SUBMODULES); do \
		if [ -f "patches/$$sub.patch" ]; then \
			echo "Pushing $$sub..."; \
			$(MAKE) push-patch-$$sub; \
		fi; \
	done

push-patch-%:
	@sub=$*; \
	cd $$sub && \
	git push -u origin $(BRANCH_PREFIX)

clean-patches:
	@for sub in $(SUBMODULES); do \
		echo "Resetting $$sub to main..."; \
		cd $$sub && git checkout main && git clean -fd && cd ..; \
	done
