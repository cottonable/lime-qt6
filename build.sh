#!/bin/bash

# Lime Editor Build Script
# Builds the Qt6 frontend with Go backend integration

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BUILD_TYPE="Release"
BUILD_DIR="build"
INSTALL_PREFIX="/usr/local"
PARALLEL_JOBS=$(nproc 2>/dev/null || echo 4)

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    # Check Go
    if ! command -v go &> /dev/null; then
        log_error "Go is not installed. Please install Go 1.21 or later."
        exit 1
    fi
    
    GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    log_info "Go version: $GO_VERSION"
    
    # Check Qt6
    if ! command -v qmake-qt6 &> /dev/null && ! command -v qmake6 &> /dev/null && ! command -v qmake &> /dev/null; then
        log_error "Qt6 qmake not found. Please install Qt6 development tools."
        exit 1
    fi
    
    # Check CMake
    if ! command -v cmake &> /dev/null; then
        log_error "CMake is not installed. Please install CMake 3.16 or later."
        exit 1
    fi
    
    CMAKE_VERSION=$(cmake --version | head -n1 | awk '{print $3}')
    log_info "CMake version: $CMAKE_VERSION"
    
    # Check for required Qt6 modules
    QT_MODULES=("Core" "Quick" "Widgets")
    for module in "${QT_MODULES[@]}"; do
        if ! pkg-config --exists Qt6${module} 2>/dev/null; then
            log_warning "Qt6${module} not found via pkg-config"
        fi
    done
    
    log_success "Dependencies check completed"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --debug)
                BUILD_TYPE="Debug"
                shift
                ;;
            --prefix)
                INSTALL_PREFIX="$2"
                shift 2
                ;;
            --jobs)
                PARALLEL_JOBS="$2"
                shift 2
                ;;
            --clean)
                CLEAN_BUILD=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help
show_help() {
    echo "Lime Editor Build Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --debug       Build in debug mode"
    echo "  --prefix PATH Installation prefix (default: /usr/local)"
    echo "  --jobs N      Number of parallel jobs (default: auto-detect)"
    echo "  --clean       Clean build directory before building"
    echo "  --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build in release mode"
    echo "  $0 --debug            # Build in debug mode"
    echo "  $0 --prefix /opt/lime # Install to /opt/lime"
    echo "  $0 --clean --debug    # Clean debug build"
}

# Clean build directory
clean_build() {
    if [ "$CLEAN_BUILD" = true ]; then
        log_info "Cleaning build directory..."
        rm -rf "$BUILD_DIR"
        log_success "Build directory cleaned"
    fi
}

# Create build directory
setup_build() {
    log_info "Setting up build directory..."
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    log_success "Build directory ready"
}

# Configure the build
configure_build() {
    log_info "Configuring build..."
    log_info "Build type: $BUILD_TYPE"
    log_info "Install prefix: $INSTALL_PREFIX"
    log_info "Parallel jobs: $PARALLEL_JOBS"
    
    # Detect Qt6 installation
    QT_CMAKE_PATH=""
    if [ -d "/usr/lib/qt6/cmake" ]; then
        QT_CMAKE_PATH="/usr/lib/qt6/cmake"
    elif [ -d "/usr/local/opt/qt@6/lib/cmake" ]; then
        QT_CMAKE_PATH="/usr/local/opt/qt@6/lib/cmake"
    elif [ -d "$HOME/Qt/6.8.0/gcc_64/lib/cmake" ]; then
        QT_CMAKE_PATH="$HOME/Qt/6.8.0/gcc_64/lib/cmake"
    fi
    
    CMAKE_ARGS=(
        -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    )
    
    if [ -n "$QT_CMAKE_PATH" ]; then
        CMAKE_ARGS+=(-DCMAKE_PREFIX_PATH="$QT_CMAKE_PATH")
        log_info "Qt6 CMake path: $QT_CMAKE_PATH"
    fi
    
    # Development mode for debug builds
    if [ "$BUILD_TYPE" = "Debug" ]; then
        CMAKE_ARGS+=(-DDEV_MODE=ON)
    fi
    
    cmake .. "${CMAKE_ARGS[@]}"
    log_success "Build configured"
}

# Build the project
build_project() {
    log_info "Building project..."
    
    # Build Go dependencies first
    log_info "Building Go dependencies..."
    cd ..
    go mod download
    go mod tidy
    cd "$BUILD_DIR"
    
    # Build the main project
    make -j"$PARALLEL_JOBS"
    
    log_success "Project built successfully"
}

# Run tests
run_tests() {
    if [ "$BUILD_TYPE" = "Debug" ]; then
        log_info "Running tests..."
        make test
        log_success "Tests completed"
    else
        log_info "Skipping tests in release mode"
    fi
}

# Create package
create_package() {
    if [ "$BUILD_TYPE" = "Release" ]; then
        log_info "Creating package..."
        cpack
        log_success "Package created"
    fi
}

# Install the project
install_project() {
    log_info "Installing project..."
    make install
    log_success "Project installed to $INSTALL_PREFIX"
}

# Main build process
main() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║        Lime Editor Build Script      ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    
    # Parse arguments
    parse_args "$@"
    
    # Check dependencies
    check_dependencies
    
    # Clean if requested
    clean_build
    
    # Setup build
    setup_build
    
    # Configure
    configure_build
    
    # Build
    build_project
    
    # Tests
    run_tests
    
    # Package
    create_package
    
    # Installation (optional)
    if [ "${1:-}" = "--install" ]; then
        install_project
    fi
    
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║           Build Complete!            ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    echo "To run the editor:"
    echo "  ./build/bin/lime-editor"
    echo ""
    echo "For development with hot-reload:"
    echo "  ./build/bin/lime-editor --dev"
    echo ""
    echo "To install system-wide:"
    echo "  $0 --install"
    echo ""
}

# Run main function
main "$@"