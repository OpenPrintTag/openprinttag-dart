.PHONY: help update-data build test clean

help:
	@echo "Available commands:"
	@echo "  make update-data  - Update data from upstream and rebuild"
	@echo "  make build        - Run code generation"
	@echo "  make test         - Run tests"
	@echo "  make clean        - Clean generated files"

update-data:
	@echo "Updating submodule from upstream..."
	git submodule update --remote --merge
	@echo "Rebuilding generated files..."
	dart run build_runner build --delete-conflicting-outputs
	@echo "Done! Check git status and commit changes."

build:
	dart run build_runner build --delete-conflicting-outputs

test:
	dart test

clean:
	dart run build_runner clean

