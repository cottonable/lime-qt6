cmake_minimum_required(VERSION 3.16)
project(lime-qt6 VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Find required packages
find_package(Qt6 REQUIRED COMPONENTS Core Quick Widgets)
find_package(Threads REQUIRED)

# Set up Go integration
find_program(GO_EXECUTABLE go)
if(NOT GO_EXECUTABLE)
    message(FATAL_ERROR "Go executable not found. Please install Go 1.21 or later.")
endif()

# Get Go version
execute_process(COMMAND ${GO_EXECUTABLE} version
    OUTPUT_VARIABLE GO_VERSION_OUTPUT
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
message(STATUS "Using Go: ${GO_VERSION_OUTPUT}")

# Set up Qt6 paths
set(Qt6_DIR "${Qt6_DIR}" CACHE PATH "Qt6 installation directory")
set(QT_QMAKE_EXECUTABLE "${Qt6_DIR}/bin/qmake" CACHE FILEPATH "Qt6 qmake executable")

# Configure Qt6
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Add definitions
add_definitions(-DQT_NO_KEYWORDS)
add_definitions(-DQT_DISABLE_DEPRECATED_BEFORE=0x060000)

# Set up build directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# Qt6 MOC and RCC processing
qt6_add_resources(RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/resources.qrc)

# Generate Go bindings
set(GO_BINDING_DIR ${CMAKE_CURRENT_BINARY_DIR}/go_bindings)
file(MAKE_DIRECTORY ${GO_BINDING_DIR})

# Custom target for Go bindings
add_custom_target(go_bindings
    COMMAND ${CMAKE_COMMAND} -E env
        CGO_ENABLED=1
        GOOS=${CMAKE_HOST_SYSTEM_NAME}
        GOARCH=${CMAKE_HOST_SYSTEM_PROCESSOR}
        ${GO_EXECUTABLE} build -buildmode=c-shared
        -o ${GO_BINDING_DIR}/liblime_go.${CMAKE_SHARED_LIBRARY_SUFFIX}
        ${CMAKE_CURRENT_SOURCE_DIR}/cmd/main.go
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Building Go bindings"
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/go.mod
)

# Main executable
add_executable(lime-qt6
    ${CMAKE_CURRENT_SOURCE_DIR}/cmd/main.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main_window.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/application_controller.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/theme_manager.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/file_system_model.cpp
    ${RESOURCES}
)

# Target properties
set_target_properties(lime-qt6 PROPERTIES
    OUTPUT_NAME "lime-editor"
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

# Link libraries
target_link_libraries(lime-qt6
    Qt6::Core
    Qt6::Quick
    Qt6::Widgets
    Threads::Threads
    ${CMAKE_DL_LIBS}
)

# Platform-specific configuration
if(WIN32)
    # Windows-specific settings
    set_target_properties(lime-qt6 PROPERTIES
        WIN32_EXECUTABLE TRUE
        LINK_FLAGS "/SUBSYSTEM:WINDOWS"
    )
    
    # Copy Qt6 DLLs
    add_custom_command(TARGET lime-qt6 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_RUNTIME_DLLS:lime-qt6>
            $<TARGET_FILE_DIR:lime-qt6>
        COMMAND_EXPAND_LISTS
    )
    
    # Windows deployment
    if(EXISTS ${QT_QMAKE_EXECUTABLE})
        add_custom_command(TARGET lime-qt6 POST_BUILD
            COMMAND ${QT_QMAKE_EXECUTABLE} -install qmlimportscanner
                -rootPath ${CMAKE_CURRENT_SOURCE_DIR}/assets/qml
                -importPath ${Qt6_DIR}/qml
                -output ${CMAKE_CURRENT_BINARY_DIR}/qml_imports.txt
        )
    endif()
    
elseif(APPLE)
    # macOS-specific settings
    set_target_properties(lime-qt6 PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_BUNDLE_NAME "Lime Editor"
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
        MACOSX_BUNDLE_GUI_IDENTIFIER "com.cottonable.lime-editor"
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in
    )
    
    # macOS deployment
    add_custom_command(TARGET lime-qt6 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${CMAKE_CURRENT_SOURCE_DIR}/assets
            $<TARGET_BUNDLE_CONTENT_DIR:lime-qt6>/Resources/assets
    )
    
else()
    # Linux-specific settings
    set_target_properties(lime-qt6 PROPERTIES
        INSTALL_RPATH_USE_LINK_PATH TRUE
        INSTALL_RPATH "$ORIGIN/../lib"
    )
    
    # Linux desktop file
    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/lime-editor.desktop.in
        ${CMAKE_CURRENT_BINARY_DIR}/lime-editor.desktop
        @ONLY
    )
    
    # Linux AppStream metadata
    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/lime-editor.appdata.xml.in
        ${CMAKE_CURRENT_BINARY_DIR}/lime-editor.appdata.xml
        @ONLY
    )
endif()

# Installation
install(TARGETS lime-qt6
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION Applications
)

# Install QML files
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/assets/qml
    DESTINATION share/lime-editor
    FILES_MATCHING PATTERN "*.qml"
)

# Install fonts
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/assets/fonts
    DESTINATION share/lime-editor/fonts
    FILES_MATCHING PATTERN "*.ttf"
)

# Install icons
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/assets/icons
    DESTINATION share/lime-editor/icons
    FILES_MATCHING PATTERN "*.svg"
)

# Install desktop file on Linux
if(UNIX AND NOT APPLE)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/lime-editor.desktop
        DESTINATION share/applications
    )
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/lime-editor.appdata.xml
        DESTINATION share/metainfo
    )
endif()

# CPack configuration
set(CPACK_PACKAGE_NAME "lime-editor")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A modern, GPU-accelerated text editor")
set(CPACK_PACKAGE_VENDOR "cottonable")
set(CPACK_PACKAGE_CONTACT "contact@cottonable.com")

# Platform-specific package generators
if(WIN32)
    set(CPACK_GENERATOR "NSIS;ZIP")
    set(CPACK_NSIS_DISPLAY_NAME "Lime Editor")
    set(CPACK_NSIS_PACKAGE_NAME "Lime Editor")
    set(CPACK_NSIS_CONTACT ${CPACK_PACKAGE_CONTACT})
    set(CPACK_NSIS_HELP_LINK "https://github.com/cottonable/lime-editor")
    set(CPACK_NSIS_URL_INFO_ABOUT "https://github.com/cottonable/lime-editor")
    set(CPACK_NSIS_MODIFY_PATH ON)
elseif(APPLE)
    set(CPACK_GENERATOR "DragNDrop;TGZ")
    set(CPACK_DMG_VOLUME_NAME "Lime Editor ${PROJECT_VERSION}")
    set(CPACK_DMG_FORMAT "UDBZ")
    set(CPACK_DMG_BACKGROUND_IMAGE ${CMAKE_CURRENT_SOURCE_DIR}/assets/dmg-background.png)
else()
    set(CPACK_GENERATOR "DEB;RPM;TGZ")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6, libstdc++6, libqt6core6, libqt6quick6, libqt6widgets6")
    set(CPACK_RPM_PACKAGE_REQUIRES "qt6-qtbase, qt6-qtdeclarative")
endif()

include(CPack)

# Development targets
add_custom_target(run
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/bin/lime-editor
    DEPENDS lime-qt6
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Running Lime Editor"
)

add_custom_target(debug
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/bin/lime-editor --debug
    DEPENDS lime-qt6
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Running Lime Editor in debug mode"
)

# Testing
enable_testing()
add_subdirectory(tests)

# Documentation
find_package(Doxygen)
if(DOXYGEN_FOUND)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in
        ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY)
    add_custom_target(doc
        ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generating API documentation with Doxygen"
        VERBATIM
    )
endif()