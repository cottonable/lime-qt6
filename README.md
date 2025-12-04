# Lime Editor - Qt6 Frontend

A modern, GPU-accelerated text editor frontend built with Qt6 and QML, designed to work with the [lime-backend](https://github.com/cottonable/lime-backend). This editor combines the familiar interface of Sublime Text 4 with modern performance optimizations and a beautiful, responsive design.

## Features

### 🎨 Modern UI Design
- **Sublime Text 4 inspired interface** with dark theme by default
- **High-DPI support** with crisp rendering on all displays
- **Custom window chrome** with modern controls
- **Smooth animations** and transitions throughout

### ⚡ Performance
- **GPU-accelerated rendering** at 120+ FPS
- **Subpixel text rendering** for crystal-clear fonts
- **Smooth scrolling** with momentum and easing
- **Efficient text layout** using Qt's text engine
- **Real-time minimap** with viewport synchronization

### 🔧 Advanced Features
- **Tab management** with drag-reorder and close buttons
- **Sidebar file explorer** with folder tree navigation
- **Command palette** (`Ctrl+Shift+P`) with fuzzy search
- **Multi-cursor support** via backend integration
- **Syntax highlighting** powered by Tree-sitter
- **Git integration** with branch indicators

### 🛠️ Developer Experience
- **Hot-reloadable QML** during development
- **Comprehensive theme system** with easy customization
- **Extensible architecture** for plugins and extensions
- **Cross-platform** support (Windows, macOS, Linux)

## Screenshots

*Screenshots will be added once the project is built and running*

## Requirements

### Build Dependencies

#### Qt6 (6.8.0 or later)
```bash
# Ubuntu/Debian
sudo apt-get install qt6-base-dev qt6-declarative-dev qt6-tools-dev-tools

# Fedora
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel

# macOS (using Homebrew)
brew install qt@6

# Windows
# Download from https://www.qt.io/download
```

#### Go (1.21 or later)
```bash
# Download from https://golang.org/dl/
# Or use package manager
brew install go      # macOS
sudo apt-get install golang-go  # Ubuntu/Debian
```

#### CMake (3.16 or later)
```bash
# Ubuntu/Debian
sudo apt-get install cmake

# macOS
brew install cmake

# Windows
# Download from https://cmake.org/download/
```

#### Additional Tools
- **Git** for version control
- **Ninja** (optional) for faster builds
- **Doxygen** (optional) for documentation generation

## Building

### Quick Start

1. **Clone the repository**
```bash
git clone https://github.com/cottonable/lime-qt6.git
cd lime-qt6
```

2. **Clone the backend** (in parent directory)
```bash
cd ..
git clone https://github.com/cottonable/lime-backend.git
cd lime-qt6
```

3. **Build using the provided script**
```bash
# Linux/macOS
./build.sh

# Windows
build.bat
```

### Manual Build

1. **Create build directory**
```bash
mkdir build
cd build
```

2. **Configure with CMake**
```bash
# Linux/macOS
cmake .. -DCMAKE_BUILD_TYPE=Release

# Windows
cmake .. -G "Visual Studio 17 2022" -A x64
```

3. **Build**
```bash
# Linux/macOS
make -j$(nproc)

# Windows
cmake --build . --config Release
```

4. **Run**
```bash
./bin/lime-editor
```

### Development Build

For development with hot-reload and debug symbols:

```bash
mkdir build-debug
cd build-debug
cmake .. -DCMAKE_BUILD_TYPE=Debug -DDEV_MODE=ON
make -j$(nproc)
```

## Usage

### Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Command Palette | `Ctrl+Shift+P` |
| Toggle Sidebar | `Ctrl+B` |
| Toggle Terminal | `Ctrl+`` |
| New File | `Ctrl+N` |
| Open File | `Ctrl+O` |
| Save File | `Ctrl+S` |
| Save All | `Ctrl+Shift+S` |
| Close File | `Ctrl+W` |
| Find | `Ctrl+F` |
| Find and Replace | `Ctrl+H` |
| Go to Line | `Ctrl+G` |
| Go to File | `Ctrl+P` |
| Zoom In | `Ctrl++` |
| Zoom Out | `Ctrl+-` |
| Reset Zoom | `Ctrl+0` |

### Command Palette

The command palette provides quick access to all editor commands:

1. Press `Ctrl+Shift+P` to open the command palette
2. Type to search for commands
3. Use arrow keys to navigate
4. Press `Enter` to execute

### File Explorer

- Navigate files and folders in the sidebar
- Click files to open them in tabs
- Use the tree view to explore project structure
- Right-click for context menu options

### Tab Management

- **Open**: Double-click files in explorer or use `Ctrl+O`
- **Close**: Click the × button or use `Ctrl+W`
- **Reorder**: Drag tabs to rearrange
- **Switch**: Click tabs or use `Ctrl+Tab`

## Configuration

### Theme Customization

The editor uses a comprehensive theme system. Themes are defined in `assets/qml/Theme.qml`:

```javascript
// Custom theme colors
property color myBackgroundColor: "#1a1a1a"
property color myTextColor: "#cccccc"
// ... more colors
```

### Settings

Settings can be accessed through the command palette:
- Search for "Preferences: Open Settings"
- Settings are stored in JSON format
- Supports user-specific overrides

### Extensions

The editor architecture supports extensions:
- Extensions are loaded from the `extensions/` directory
- Each extension is a separate Go module
- Extensions can add commands, themes, and functionality

## Development

### Project Structure

```
lime-qt6/
├── cmd/                    # Application entry points
│   └── main.go            # Main application
├── internal/              # Internal packages
│   ├── editor/           # Editor core (EditorItem)
│   └── ui/               # UI components and controllers
├── assets/               # Assets and resources
│   ├── qml/             # QML files
│   ├── fonts/           # Font files
│   └── icons/           # Icon files
├── pkg/                  # Public packages
├── build/               # Build scripts and configuration
├── tests/               # Test files
└── docs/               # Documentation
```

### Adding New Features

1. **QML Components**: Add new `.qml` files in `assets/qml/`
2. **Go Components**: Add new packages in `internal/` or `pkg/`
3. **Backend Integration**: Use the lime-backend API
4. **Themes**: Extend the theme system in `Theme.qml`

### Debugging

Enable debug mode for detailed logging:
```bash
./lime-editor --debug
```

### Testing

Run tests:
```bash
cd build
make test
```

### Performance Profiling

Enable performance metrics:
```bash
./lime-editor --profile
```

## Deployment

### Creating Packages

The build system supports creating packages for all platforms:

```bash
# Create all packages
cd build
cpack

# Platform-specific packages
cpack -G DEB    # Debian package
cpack -G RPM    # RPM package  
cpack -G NSIS   # Windows installer
cpack -G DragNDrop  # macOS app bundle
```

### Distribution

1. **Windows**: Use the NSIS installer
2. **macOS**: Use the DMG bundle
3. **Linux**: Use AppImage, DEB, or RPM packages

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Code Style

- Follow Go conventions for Go code
- Follow QML best practices for QML code
- Use meaningful commit messages
- Add documentation for new features

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Sublime Text** for UI inspiration
- **Qt Company** for the excellent Qt framework
- **JetBrains** for the JetBrains Mono font
- **Go community** for the powerful backend tools

## Support

- **Issues**: Report bugs via [GitHub Issues](https://github.com/cottonable/lime-qt6/issues)
- **Discussions**: Join our [GitHub Discussions](https://github.com/cottonable/lime-qt6/discussions)
- **Discord**: [Join our community server](https://discord.gg/lime-editor)

## Roadmap

### Version 1.1 (Coming Soon)
- [ ] Plugin system
- [ ] Advanced search and replace
- [ ] Git integration improvements
- [ ] Language server protocol support

### Version 1.2 (Future)
- [ ] Collaborative editing
- [ ] Advanced debugging support
- [ ] Cloud sync capabilities
- [ ] AI-powered features

---

**Built with ❤️ for developers, by developers**