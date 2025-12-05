# Makefile for Lime Editor
# Simple build system for the Go-based Qt6 editor

.PHONY: all build clean install run test

# Default target
all: build

# Build the application
build:
	@echo "Building Lime Editor..."
	@mkdir -p build
	@go build -o build/lime-editor main.go
	@echo "Build complete: ./build/lime-editor"

# Run the application
run: build
	@echo "Running Lime Editor..."
	@./build/lime-editor

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf build
	@rm -f lime-editor
	@echo "Clean complete"

# Install the application
install: build
	@echo "Installing Lime Editor..."
	@install -D -m 755 build/lime-editor /usr/local/bin/lime-editor
	@echo "Installation complete"

# Test build
test:
	@echo "Testing build..."
	@go build -o /tmp/lime-editor-test main.go
	@rm -f /tmp/lime-editor-test
	@echo "Test build successful"

# Development commands
deps:
	@echo "Installing dependencies..."
	@go mod tidy
	@go mod download
	@echo "Dependencies installed"

fmt:
	@echo "Formatting code..."
	@go fmt ./...
	@echo "Code formatted"

# Help
help:
	@echo "Lime Editor Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make build    - Build the application"
	@echo "  make run      - Build and run the application"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make install  - Install to /usr/local/bin"
	@echo "  make test     - Test build"
	@echo "  make deps     - Install dependencies"
	@echo "  make fmt      - Format code"
	@echo "  make help     - Show this help"

# Default help
.DEFAULT_GOAL := help