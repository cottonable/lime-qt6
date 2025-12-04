import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Dialogs 1.3
import LimeEditor 1.0

ApplicationWindow {
    id: mainWindow
    
    // Window properties
    visible: true
    width: 1400
    height: 900
    minimumWidth: 800
    minimumHeight: 600
    title: "Lime Editor"
    color: Theme.backgroundColor
    
    // Enable smooth rendering
    flags: Qt.Window | Qt.FramelessWindowHint
    visibility: Window.Maximized
    
    // Custom property for window state
    property bool maximized: false
    property bool fullscreen: false
    property var currentTheme: ThemeManager.currentTheme
    
    // Font loading
    FontLoader {
        id: jetBrainsMono
        source: "qrc:/assets/fonts/JetBrainsMono-Regular.ttf"
    }
    
    // Keyboard shortcuts
    Shortcut {
        sequence: "Ctrl+Shift+P"
        onActivated: commandPalette.open()
    }
    
    Shortcut {
        sequence: "Ctrl+`"
        onActivated: terminal.toggle()
    }
    
    Shortcut {
        sequence: "Ctrl+B"
        onActivated: sidebar.toggle()
    }
    
    // Main layout
    Rectangle {
        id: mainContainer
        anchors.fill: parent
        color: Theme.backgroundColor
        
        // Custom window chrome
        Rectangle {
            id: titleBar
            height: 28
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            color: Theme.titleBarColor
            
            RowLayout {
                anchors {
                    left: parent.left
                    leftMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                spacing: 8
                
                Text {
                    text: mainWindow.title
                    color: Theme.textColor
                    font {
                        family: jetBrainsMono.name
                        pixelSize: 12
                        weight: Font.Medium
                    }
                    opacity: 0.8
                }
                
                Text {
                    text: AppController.currentFile ? AppController.currentFile : "Untitled"
                    color: Theme.textColor
                    font {
                        family: jetBrainsMono.name
                        pixelSize: 11
                    }
                    opacity: 0.6
                }
            }
            
            // Window controls
            RowLayout {
                anchors {
                    right: parent.right
                    rightMargin: 8
                    verticalCenter: parent.verticalCenter
                }
                spacing: 4
                
                Rectangle {
                    width: 12; height: 12
                    radius: 6
                    color: "#FF5F56"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: mainWindow.close()
                    }
                }
                Rectangle {
                    width: 12; height: 12
                    radius: 6
                    color: "#FFBD2E"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: mainWindow.showMinimized()
                    }
                }
                Rectangle {
                    width: 12; height: 12
                    radius: 6
                    color: "#27CA3F"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (mainWindow.visibility === Window.Maximized) {
                                mainWindow.showNormal()
                            } else {
                                mainWindow.showMaximized()
                            }
                        }
                    }
                }
            }
        }
        
        // Content area
        Item {
            id: contentArea
            anchors {
                top: titleBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            
            // Splitter for resizable panels
            SplitView {
                id: mainSplitter
                anchors.fill: parent
                orientation: Qt.Horizontal
                
                // Sidebar
                Sidebar {
                    id: sidebar
                    Layout.minimumWidth: 200
                    Layout.preferredWidth: 220
                    Layout.maximumWidth: 400
                    visible: AppController.sidebarVisible
                    onFileOpened: AppController.openFile(filePath)
                }
                
                // Main editor area
                Rectangle {
                    id: editorContainer
                    color: Theme.editorBackgroundColor
                    Layout.fillWidth: true
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0
                        
                        // Tab bar
                        TabBar {
                            id: tabBar
                            Layout.fillWidth: true
                            Layout.preferredHeight: 35
                            onTabSelected: AppController.selectTab(index)
                            onTabClosed: AppController.closeTab(index)
                            onTabReordered: AppController.reorderTabs(fromIndex, toIndex)
                        }
                        
                        // Editor view with minimap
                        SplitView {
                            id: editorSplitter
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            orientation: Qt.Horizontal
                            
                            // Editor view
                            EditorView {
                                id: editorView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onTextChanged: AppController.handleTextChange(text)
                                onCursorPositionChanged: AppController.updateCursorPosition(line, column)
                                onSelectionChanged: AppController.updateSelection(startLine, endLine)
                            }
                            
                            // Minimap
                            Minimap {
                                id: minimap
                                Layout.preferredWidth: 120
                                Layout.maximumWidth: 150
                                Layout.minimumWidth: 100
                                Layout.fillHeight: true
                                editorView: editorView
                                onScrollToLine: editorView.scrollToLine(line)
                            }
                        }
                        
                        // Status bar
                        StatusBar {
                            id: statusBar
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                            onToggleSidebar: sidebar.toggle()
                            onToggleTerminal: terminal.toggle()
                        }
                    }
                }
                
                // Terminal panel (optional)
                Rectangle {
                    id: terminal
                    color: Theme.terminalBackgroundColor
                    Layout.preferredHeight: 250
                    Layout.minimumHeight: 150
                    Layout.maximumHeight: 500
                    visible: AppController.terminalVisible
                    
                    Text {
                        text: "Terminal"
                        color: Theme.textColor
                        anchors.centerIn: parent
                        font.family: jetBrainsMono.name
                    }
                }
            }
        }
    }
    
    // Command palette overlay
    CommandPalette {
        id: commandPalette
        anchors.centerIn: parent
        width: 600
        height: 400
        onCommandSelected: AppController.executeCommand(command)
    }
    
    // File open dialog
    FileDialog {
        id: fileDialog
        title: "Open File"
        folder: shortcuts.home
        selectExisting: true
        selectFolder: false
        selectMultiple: false
        nameFilters: ["All files (*)"]
        onAccepted: {
            AppController.openFile(fileUrl.toString().replace("file://", ""))
        }
    }
    
    // Component initialization
    Component.onCompleted: {
        // Load theme
        ThemeManager.loadTheme("sublime-dark")
        
        // Initialize application
        AppController.initialize()
        
        // Set up window chrome drag
        setupWindowChrome()
    }
    
    function setupWindowChrome() {
        // Enable window dragging from title bar
        titleBar.MouseArea {
            anchors.fill: parent
            property var clickPos: "0,0"
            onPressed: {
                clickPos = Qt.point(mouse.x, mouse.y)
            }
            onMouseXChanged: {
                if (pressedButtons & Qt.LeftButton) {
                    var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                    mainWindow.x += delta.x
                    mainWindow.y += delta.y
                }
            }
        }
    }
    
    // Global mouse handling for context menus
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: mouse.accepted = false
        onDoubleClicked: mouse.accepted = false
    }
}