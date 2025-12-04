@echo off
REM Lime Editor Build Script for Windows
REM Builds the Qt6 frontend with Go backend integration

setlocal EnableDelayedExpansion

REM Configuration
set BUILD_TYPE=Release
set BUILD_DIR=build
set INSTALL_PREFIX=C:\Program Files\LimeEditor
set PARALLEL_JOBS=%NUMBER_OF_PROCESSORS%

REM Colors (limited in batch)
set "BLUE=[94m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "NC=[0m"

REM Functions
:log_info
echo %BLUE%[INFO]%NC% %~1
goto :eof

:log_success
echo %GREEN%[SUCCESS]%NC% %~1
goto :eof

:log_warning
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

:log_error
echo %RED%[ERROR]%NC% %~1
goto :eof

REM Check dependencies
:check_dependencies
call :log_info "Checking dependencies..."

REM Check Go
where go >nul 2>nul
if %errorlevel% neq 0 (
    call :log_error "Go is not installed or not in PATH. Please install Go 1.21 or later."
    exit /b 1
)

for /f "tokens=3" %%i in ('go version') do set GO_VERSION=%%i
call :log_info "Go version: !GO_VERSION!"

REM Check Qt6
where qmake >nul 2>nul
if %errorlevel% neq 0 (
    where qmake6 >nul 2>nul
    if %errorlevel% neq 0 (
        call :log_error "Qt6 qmake not found. Please install Qt6 and add it to PATH."
        exit /b 1
    ) else (
        set QMAKE=qmake6
    )
) else (
    set QMAKE=qmake
)

REM Check CMake
where cmake >nul 2>nul
if %errorlevel% neq 0 (
    call :log_error "CMake is not installed or not in PATH. Please install CMake 3.16 or later."
    exit /b 1
)

for /f "tokens=3" %%i in ('cmake --version') do set CMAKE_VERSION=%%i
call :log_info "CMake version: !CMAKE_VERSION!"

call :log_success "Dependencies check completed"
goto :eof

REM Parse command line arguments
:parse_args
:parse_loop
if "%~1"=="" goto :eof
if "%~1"=="--debug" (
    set BUILD_TYPE=Debug
    shift
    goto :parse_loop
)
if "%~1"=="--prefix" (
    set INSTALL_PREFIX=%~2
    shift
    shift
    goto :parse_loop
)
if "%~1"=="--jobs" (
    set PARALLEL_JOBS=%~2
    shift
    shift
    goto :parse_loop
)
if "%~1"=="--clean" (
    set CLEAN_BUILD=true
    shift
    goto :parse_loop
)
if "%~1"=="--help" (
    call :show_help
    exit /b 0
)
call :log_error "Unknown option: %~1"
call :show_help
exit /b 1

REM Show help
:show_help
echo Lime Editor Build Script for Windows
echo.
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo   --debug       Build in debug mode
echo   --prefix PATH Installation prefix (default: C:\Program Files\LimeEditor)
echo   --jobs N      Number of parallel jobs (default: NUMBER_OF_PROCESSORS)
echo   --clean       Clean build directory before building
echo   --help        Show this help message
echo.
echo Examples:
echo   %0                    # Build in release mode
echo   %0 --debug            # Build in debug mode
echo   %0 --prefix "C:\Tools\Lime" # Install to C:\Tools\Lime
echo   %0 --clean --debug    # Clean debug build
exit /b 0

REM Clean build directory
:clean_build
if "%CLEAN_BUILD%"=="true" (
    call :log_info "Cleaning build directory..."
    if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
    call :log_success "Build directory cleaned"
)
goto :eof

REM Create build directory
:setup_build
call :log_info "Setting up build directory..."
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd "%BUILD_DIR%"
call :log_success "Build directory ready"
goto :eof

REM Configure the build
:configure_build
call :log_info "Configuring build..."
call :log_info "Build type: %BUILD_TYPE%"
call :log_info "Install prefix: %INSTALL_PREFIX%"
call :log_info "Parallel jobs: %PARALLEL_JOBS%"

REM Detect Qt6 installation
set QT_CMAKE_PATH=
if exist "C:\Qt\6.8.0\msvc2019_64\lib\cmake" (
    set QT_CMAKE_PATH=C:\Qt\6.8.0\msvc2019_64\lib\cmake
) else if exist "C:\Qt\6.8.0\mingw_64\lib\cmake" (
    set QT_CMAKE_PATH=C:\Qt\6.8.0\mingw_64\lib\cmake
)

set CMAKE_ARGS=-DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

if defined QT_CMAKE_PATH (
    set CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_PREFIX_PATH="%QT_CMAKE_PATH%"
    call :log_info "Qt6 CMake path: %QT_CMAKE_PATH%"
)

REM Development mode for debug builds
if "%BUILD_TYPE%"=="Debug" (
    set CMAKE_ARGS=%CMAKE_ARGS% -DDEV_MODE=ON
)

cmake .. %CMAKE_ARGS%
if %errorlevel% neq 0 (
    call :log_error "CMake configuration failed"
    exit /b 1
)
call :log_success "Build configured"
goto :eof

REM Build the project
:build_project
call :log_info "Building project..."

REM Build Go dependencies first
call :log_info "Building Go dependencies..."
cd ..
go mod download
if %errorlevel% neq 0 (
    call :log_error "Go mod download failed"
    exit /b 1
)
go mod tidy
if %errorlevel% neq 0 (
    call :log_error "Go mod tidy failed"
    exit /b 1
)
cd "%BUILD_DIR%"

REM Build the main project
cmake --build . --config %BUILD_TYPE% --parallel %PARALLEL_JOBS%
if %errorlevel% neq 0 (
    call :log_error "Build failed"
    exit /b 1
)

call :log_success "Project built successfully"
goto :eof

REM Run tests
:run_tests
if "%BUILD_TYPE%"=="Debug" (
    call :log_info "Running tests..."
    cmake --build . --target test --config %BUILD_TYPE%
    if %errorlevel% neq 0 (
        call :log_warning "Some tests failed"
    ) else (
        call :log_success "Tests completed"
    )
) else (
    call :log_info "Skipping tests in release mode"
)
goto :eof

REM Create package
:create_package
if "%BUILD_TYPE%"=="Release" (
    call :log_info "Creating package..."
    cpack -C %BUILD_TYPE%
    if %errorlevel% neq 0 (
        call :log_warning "Package creation failed"
    ) else (
        call :log_success "Package created"
    )
)
goto :eof

REM Main build process
:main
echo.
echo ╔══════════════════════════════════════╗
echo ║        Lime Editor Build Script      ║
echo ╚══════════════════════════════════════╝
echo.

REM Parse arguments
call :parse_args %*

REM Check dependencies
call :check_dependencies

REM Clean if requested
call :clean_build

REM Setup build
call :setup_build

REM Configure
call :configure_build

REM Build
call :build_project

REM Tests
call :run_tests

REM Package
call :create_package

echo.
echo ╔══════════════════════════════════════╗
echo ║           Build Complete!            ║
echo ╚══════════════════════════════════════╝
echo.
echo To run the editor:
echo   build\bin\%BUILD_TYPE%\lime-editor.exe
echo.
echo For development with hot-reload:
echo   build\bin\%BUILD_TYPE%\lime-editor.exe --dev
echo.
goto :eof

REM Run main function
call :main %*