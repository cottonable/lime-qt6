# CMakeLists.txt for Lime Editor Qt6 Application

cmake_minimum_required(VERSION 3.16)
project(lime-editor VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Find Qt6 packages
find_package(Qt6 REQUIRED COMPONENTS Core Quick Qml)

# Enable automatic MOC, UIC, and RCC processing
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# Define QML files
set(QML_FILES
    main.qml
    EditorView.qml
)

# Create resources file
qt6_add_resources(RESOURCES
    resources.qrc
)

# Create a simple C++ launcher that embeds the Go application
# This is a placeholder - the actual build will use Go
add_executable(${PROJECT_NAME}
    ${RESOURCES}
)

# For now, create a simple wrapper that will be replaced by Go build
target_link_libraries(${PROJECT_NAME}
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
)

# Custom target to build Go application
add_custom_target(build_go ALL
    COMMAND go build -o ${CMAKE_BINARY_DIR}/lime-editor ${CMAKE_SOURCE_DIR}/main.go
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Building Go application"
)

# Installation rules
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
)

# Install QML files for development
install(FILES ${QML_FILES}
    DESTINATION share/lime-editor/qml
)

# CPack configuration
set(CPACK_PACKAGE_NAME "Lime Editor")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A modern text editor built with Qt6 and Go")
set(CPACK_PACKAGE_VENDOR "Cottonable")

include(CPack)