# ap-base Makefile
# Submodule management

.PHONY: init deinit help

SUBMODULES := $(shell git submodule status | awk '{print $$2}' | xargs)

help:
	@echo "ap-base submodule management"
	@echo ""
	@echo "Targets:"
	@echo "  init           - Initialize and update all submodules"
	@echo "  deinit         - Deinitialize submodules and clear cache (clean slate)"

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
