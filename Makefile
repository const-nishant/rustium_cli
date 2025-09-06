# Makefile for Rustium CLI
# Provides convenient commands for development and versioning

.PHONY: help build test clean install release-patch release-minor release-major release-set

# Default target
help:
	@echo "🦀 Rustium CLI - Available Commands"
	@echo "=================================="
	@echo ""
	@echo "Development:"
	@echo "  build          Build the project in release mode"
	@echo "  test           Run tests"
	@echo "  clean          Clean build artifacts"
	@echo "  install        Install the CLI tool"
	@echo "  run            Run the CLI tool"
	@echo ""
	@echo "Versioning:"
	@echo "  release-patch  Release a patch version (0.1.0 -> 0.1.1)"
	@echo "  release-minor  Release a minor version (0.1.0 -> 0.2.0)"
	@echo "  release-major  Release a major version (0.1.0 -> 1.0.0)"
	@echo "  release-set    Release a specific version (usage: make release-set VERSION=1.2.3)"
	@echo ""
	@echo "Utilities:"
	@echo "  check          Run clippy and format checks"
	@echo "  fmt            Format code"
	@echo "  clippy         Run clippy lints"

# Development commands
build:
	@echo "🔨 Building Rustium CLI..."
	cargo build --release

test:
	@echo "🧪 Running tests..."
	cargo test

clean:
	@echo "🧹 Cleaning build artifacts..."
	cargo clean

install:
	@echo "📦 Installing Rustium CLI..."
	cargo install --path .

run:
	@echo "🚀 Running Rustium CLI..."
	cargo run

# Code quality commands
check: fmt clippy
	@echo "✅ All checks passed!"

fmt:
	@echo "🎨 Formatting code..."
	cargo fmt --all

clippy:
	@echo "🔍 Running clippy..."
	cargo clippy --all-targets --all-features -- -D warnings

# Versioning commands
release-patch:
	@echo "📦 Releasing patch version..."
ifeq ($(OS),Windows_NT)
	@powershell -ExecutionPolicy Bypass -File scripts/version.ps1 patch
else
	@./scripts/version.sh patch
endif

release-minor:
	@echo "📦 Releasing minor version..."
ifeq ($(OS),Windows_NT)
	@powershell -ExecutionPolicy Bypass -File scripts/version.ps1 minor
else
	@./scripts/version.sh minor
endif

release-major:
	@echo "📦 Releasing major version..."
ifeq ($(OS),Windows_NT)
	@powershell -ExecutionPolicy Bypass -File scripts/version.ps1 major
else
	@./scripts/version.sh major
endif

release-set:
	@echo "📦 Releasing version $(VERSION)..."
ifeq ($(OS),Windows_NT)
	@powershell -ExecutionPolicy Bypass -File scripts/version.ps1 set $(VERSION)
else
	@./scripts/version.sh set $(VERSION)
endif

# Validate version parameter for release-set
ifdef VERSION
release-set: validate-version
endif

validate-version:
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Error: VERSION parameter is required for release-set"; \
		echo "Usage: make release-set VERSION=1.2.3"; \
		exit 1; \
	fi
