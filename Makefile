# Makefile for AdGuardHome
# Provides common build, test, and lint targets.

.PHONY: all build clean deps lint test vet fmt help

# Go binary
GO ?= go

# Build output directory
OUT_DIR ?= ./build

# Binary name
BINARY ?= AdGuardHome

# Version information
VERSION ?= $(shell git describe --abbrev=4 --dirty --tags 2>/dev/null || echo "dev")
BUILD_TIME ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_COMMIT ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Linker flags
LDFLAGS := -ldflags "-s -w \
	-X github.com/AdguardTeam/AdGuardHome/internal/version.version=$(VERSION) \
	-X github.com/AdguardTeam/AdGuardHome/internal/version.buildtime=$(BUILD_TIME) \
	-X github.com/AdguardTeam/AdGuardHome/internal/version.channel=development \
	-X github.com/AdguardTeam/AdGuardHome/internal/version.commitid=$(GIT_COMMIT)"

# Default target
all: build

## help: Print this help message.
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@sed -n 's/^## //p' $(MAKEFILE_LIST) | column -t -s ':' | sed -e 's/^/  /'

## deps: Download Go module dependencies.
deps:
	$(GO) mod download
	$(GO) mod verify

## build: Build the AdGuardHome binary.
build: deps
	@mkdir -p $(OUT_DIR)
	$(GO) build $(LDFLAGS) -o $(OUT_DIR)/$(BINARY) ./main.go

## clean: Remove build artifacts.
clean:
	@rm -rf $(OUT_DIR)
	@rm -f coverage.out coverage.html
	@echo "Cleaned build artifacts."

## fmt: Format Go source files.
fmt:
	$(GO) fmt ./...

## vet: Run go vet on all packages.
vet:
	$(GO) vet ./...

## lint: Run golangci-lint.
lint:
	@which golangci-lint > /dev/null 2>&1 || { echo "golangci-lint not found, install it first."; exit 1; }
	golangci-lint run ./...

## test: Run all unit tests with race detection.
test:
	$(GO) test -race -count=1 -coverprofile=coverage.out ./...

## test-short: Run short unit tests.
test-short:
	$(GO) test -short -count=1 ./...

## coverage: Generate and display test coverage report.
coverage: test
	$(GO) tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report written to coverage.html"

## run: Build and run AdGuardHome with default flags.
# Using --no-check-update to avoid update prompts, --verbose for easier debugging,
# and --web-addr to bind only to localhost for personal/local use.
# Port changed to 3001 to avoid conflict with other local services on my machine.
# --dns-addr binds DNS to localhost only since this is just for local testing,
# not meant to serve the whole network.
# --work-dir stores config/data in ./run-data so it doesn't clutter the repo root.
# NOTE: run 'sudo make run' if port 53 is needed; 127.0.0.1 is fine for local dev.
run: build
	$(OUT_DIR)/$(BINARY) --no-check-update --verbose --web-addr 127.0.0.1:3001 --dns-addr 127.0.0.1:5353 --work-dir ./run-data

## run-reset: Remove run-data and start fresh (useful when config gets into a bad state).
run-reset:
	@rm -rf ./run-data
	@echo "Removed ./run-data. Run 'make run' to start fresh."
