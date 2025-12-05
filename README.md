# Lime Editor - Qt6 Text Editor

A modern, high-performance text editor built with Qt6 and Go, inspired by Sublime Text.

## Features

- **Qt6 Framework**: Built with the latest Qt6 for modern UI and performance
- **Custom Text Rendering**: QQuickPaintedItem-based editor with crisp text rendering
- **Go Backend**: High-performance backend written in Go
- **Sublime-like Interface**: Familiar interface with tabs, sidebar, and status bar
- **Cross-platform**: Works on Windows, macOS, and Linux
- **Extensible Architecture**: Plugin system and customization support

## Project Structure

```
lime-qt6/
├── main.go              # Main Go application with Qt binding
├── go.mod              # Go module definition
├── main.qml            # Main QML interface
├── EditorView.qml      # Custom editor component
├── resources.qrc       # Qt resource file
├── CMakeLists.txt      # CMake build configuration
├── build.sh           # Build script
└── README.md          # This file
```

## Building from Source

### Prerequisites

1. **Qt6 Development Tools**:
   - Qt6 Core, Quick, Qml modules
   - Qt6 development tools (qmake, moc, etc.)

2. **Go Development Environment**:
   - Go 1.21 or later
   - therecipe/qt bindings

3. **Build Tools**:
   - CMake 3.16 or later
   - Make or Ninja
   - C++ compiler (GCC, Clang, or MSVC)

### Build Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/cottonable/lime-qt6.git
   cd lime-qt6
   ```

2. **Install Qt6 bindings for Go**:
   ```bash
   go get -u github.com/therecipe/qt/cmd/...
   $(go env GOPATH)/bin/qtsetup
   ```

3. **Build the application**:
   ```bash
   ./build.sh
   ```

   Or manually:
   ```bash
   mkdir build
   cd build
   cmake ..
   make
   ```

4. **Run the editor**:
   ```bash
   ./lime-editor
   ```

## Architecture

### Frontend (QML/QtQuick)
- **main.qml**: Main application window with menu bar and layout
- **EditorView.qml**: Custom text editor component
- **QtQuick Controls**: Modern UI components

### Backend (Go)
- **main.go**: Application entry point with Qt integration
- **Backend struct**: Provides data and functionality to QML
- **EditorView**: Custom QQuickPaintedItem for text rendering

### C++ Bridge (Optional)
For better performance, the editor includes C++ files:
- **editorview.h/cpp**: Native Qt6 implementation
- **main.cpp**: Alternative C++ entry point

## Usage

1. **Basic Text Editing**:
   - Type in the editor area
   - Use arrow keys for navigation
   - Standard keyboard shortcuts work

2. **File Operations**:
   - `Ctrl+N`: New file
   - `Ctrl+O`: Open file
   - `Ctrl+S`: Save file

3. **Editing Features**:
   - `Ctrl+F`: Find
   - `Ctrl+H`: Replace
   - `Ctrl+Z`: Undo
   - `Ctrl+Y`: Redo

4. **View Options**:
   - `Ctrl++`: Zoom in
   - `Ctrl+-`: Zoom out
   - `Ctrl+0`: Reset zoom
   - Toggle sidebar visibility

## Development

### Adding Features

1. **New QML Components**: Add to resources.qrc and load in main.qml
2. **Backend Methods**: Add to Backend struct in main.go
3. **Custom Painting**: Extend EditorView.paint() method
4. **Keyboard Shortcuts**: Add Shortcut components in QML

### Building with Different Configurations

```bash
# Debug build
cmake .. -DCMAKE_BUILD_TYPE=Debug

# Release build with optimizations
cmake .. -DCMAKE_BUILD_TYPE=Release

# Static linking
cmake .. -DCMAKE_BUILD_TYPE=Release -DQT_STATIC_BUILD=ON
```

## Troubleshooting

### Common Issues

1. **Qt6 not found**:
   - Install Qt6 development packages
   - Set QTDIR environment variable
   - Use `-DCMAKE_PREFIX_PATH=/path/to/qt6`

2. **Go bindings not working**:
   - Run `qtsetup` again
   - Check Go module cache
   - Ensure Qt6 is in PATH

3. **Build failures**:
   - Clear build directory and retry
   - Check compiler compatibility
   - Verify all dependencies are installed

### Platform-Specific Notes

**Linux**:
- Install packages: `qt6-base-dev`, `qt6-declarative-dev`
- May need to set `PKG_CONFIG_PATH`

**macOS**:
- Use Homebrew: `brew install qt@6`
- Set environment: `export CMAKE_PREFIX_PATH=/usr/local/opt/qt@6`

**Windows**:
- Use Qt Online Installer
- Set environment variables in build script
- Use Visual Studio or MinGW compiler

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple platforms
5. Submit a pull request

## License

This project is part of the Lime Editor ecosystem. See individual component licenses for details.

## Acknowledgments

- Inspired by Sublime Text and VS Code
- Built with Qt6 framework
- Uses therecipe/qt Go bindings
- Community contributions welcome!