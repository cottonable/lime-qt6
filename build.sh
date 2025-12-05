#!/bin/bash

# Lime Editor Build Script
# This script builds the Qt6-based text editor using CMake

set -e  # Exit on any error

echo "=========================================="
echo "Lime Editor Build Script"
echo "=========================================="

# Check if required tools are available
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "ERROR: $1 is required but not installed."
        echo "Please install $1 and try again."
        exit 1
    fi
}

echo "Checking required tools..."
check_command cmake
check_command make
check_command g++
check_command qmake

echo "All required tools are available!"
echo ""

# Create build directory
echo "Creating build directory..."
if [ -d "build" ]; then
    echo "Build directory exists, removing..."
    rm -rf build
fi

mkdir -p build
cd build

# Configure with CMake
echo ""
echo "Configuring with CMake..."
echo "=========================================="
cmake .. -DCMAKE_BUILD_TYPE=Release

echo ""
echo "Building with make..."
echo "=========================================="
make -j$(nproc)

echo ""
echo "Build completed successfully!"
echo "=========================================="
echo "Executable: ./lime-editor"
echo ""
echo "To run the editor:"
echo "  ./lime-editor"
echo ""
echo "To install system-wide:"
echo "  sudo make install"
echo ""
echo "To create a package:"
echo "  make package"