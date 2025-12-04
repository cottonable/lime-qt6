import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import LimeEditor 1.0

Rectangle {
    id: sidebar
    
    // Properties
    property var rootPath: ""
    property var currentPath: ""
    property bool showHiddenFiles: false
    
    // Signals
    signal fileOpened(string filePath)
    signal folderOpened(string folderPath)
    
    // Custom properties
    property var fileSystemModel: null
    property var expandedFolders: []
    property var selectedFile: ""
    
    // Background
    color: Theme.sidebarBackgroundColor
    
    // Layout
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Header
        Rectangle {
            id: sidebarHeader
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Theme.sidebarHeaderBackgroundColor
            
            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                    rightMargin: 8
                }
                spacing: 8
                
                // Explorer icon
                Rectangle {
                    width: 16
                    height: 16
                    color: Theme.sidebarHeaderIconColor
                    radius: 2
                    
                    Text {
                        anchors.centerIn: parent
                        text: "📁"
                        font.pixelSize: 10
                    }
                }
                
                // Title
                Text {
                    text: "EXPLORER"
                    color: Theme.sidebarHeaderTextColor
                    font {
                        family: Theme.editorFontFamily
                        pixelSize: 11
                        weight: Font.Medium
                    }
                    opacity: 0.8
                }
                
                // Settings button
                Rectangle {
                    width: 20
                    height: 20
                    color: "transparent"
                    radius: 10
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⚙"
                        color: Theme.sidebarSettingsIconColor
                        font.pixelSize: 12
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Theme.sidebarSettingsHoverBackground
                        onExited: parent.color = "transparent"
                        onClicked: AppController.showExplorerSettings()
                    }
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }
                }
            }
        }
        
        // File tree
        TreeView {
            id: fileTree
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // Model
            model: FileSystemModel {
                id: fileSystemModel
                rootPath: sidebar.rootPath
                showHiddenFiles: sidebar.showHiddenFiles
                nameFilters: ["*"]
                nameFilterDisables: false
            }
            
            // Columns
            TableViewColumn {
                title: "Name"
                role: "fileName"
                resizable: false
                movable: false
            }
            
            // Styling
            style: TreeViewStyle {
                backgroundColor: Theme.sidebarBackgroundColor
                alternateBackgroundColor: Theme.sidebarAlternateBackgroundColor
                
                frame: Rectangle {
                    color: "transparent"
                    border.color: "transparent"
                }
                
                branchDelegate: Item {
                    width: 16
                    height: 16
                    
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.6
                        height: parent.height * 0.6
                        color: styleData.isExpanded ? 
                            Theme.sidebarExpandedIconColor : 
                            Theme.sidebarCollapsedIconColor
                        
                        Text {
                            anchors.centerIn: parent
                            text: styleData.isExpanded ? "▼" : "▶"
                            color: parent.color
                            font.pixelSize: 8
                        }
                    }
                }
                
                rowDelegate: Rectangle {
                    color: {
                        if (styleData.selected) return Theme.sidebarSelectedBackgroundColor
                        else if (styleData.alternate) return Theme.sidebarAlternateBackgroundColor
                        else return Theme.sidebarBackgroundColor
                    }
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }
                }
                
                itemDelegate: Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    height: 24
                    color: "transparent"
                    
                    RowLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: 4
                            rightMargin: 4
                        }
                        spacing: 8
                        
                        // File/folder icon
                        Rectangle {
                            width: 16
                            height: 16
                            color: {
                                if (styleData.isFolder) {
                                    return styleData.isExpanded ? 
                                        Theme.sidebarFolderOpenIconColor : 
                                        Theme.sidebarFolderIconColor
                                } else {
                                    return Theme.sidebarFileIconColor
                                }
                            }
                            radius: 2
                            
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if (styleData.isFolder) {
                                        return styleData.isExpanded ? "📂" : "📁"
                                    } else {
                                        var ext = styleData.value.split('.').pop().toLowerCase()
                                        return getFileIcon(ext)
                                    }
                                }
                                font.pixelSize: 10
                            }
                        }
                        
                        // File name
                        Text {
                            text: styleData.value
                            color: {
                                if (styleData.selected) return Theme.sidebarSelectedTextColor
                                else return Theme.sidebarTextColor
                            }
                            font {
                                family: Theme.editorFontFamily
                                pixelSize: 12
                                weight: styleData.isFolder ? Font.Medium : Font.Normal
                            }
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (styleData.isFolder) {
                                fileTree.toggleExpanded(styleData.index)
                                folderOpened(styleData.model.filePath(styleData.index))
                            } else {
                                fileTree.selection.clear()
                                fileTree.selection.select(styleData.index)
                                selectedFile = styleData.model.filePath(styleData.index)
                                fileOpened(selectedFile)
                            }
                        }
                        onDoubleClicked: {
                            if (!styleData.isFolder) {
                                fileOpened(styleData.model.filePath(styleData.index))
                            }
                        }
                    }
                }
            }
            
            // Selection handling
            onClicked: {
                var index = fileTree.currentIndex
                if (index.isValid()) {
                    var filePath = fileSystemModel.filePath(index)
                    if (fileSystemModel.isDir(index)) {
                        folderOpened(filePath)
                    } else {
                        selectedFile = filePath
                        fileOpened(filePath)
                    }
                }
            }
            
            onDoubleClicked: {
                var index = fileTree.currentIndex
                if (index.isValid() && !fileSystemModel.isDir(index)) {
                    fileOpened(fileSystemModel.filePath(index))
                }
            }
        }
        
        // Resize handle
        Rectangle {
            id: resizeHandle
            Layout.fillWidth: true
            Layout.preferredHeight: 4
            color: "transparent"
            
            MouseArea {
                anchors.fill: parent
                anchors.bottomMargin: -2
                anchors.topMargin: -2
                cursorShape: Qt.SizeVerCursor
                
                property real startY: 0
                
                onPressed: {
                    startY = mouse.y
                }
                
                onPositionChanged: {
                    var delta = mouse.y - startY
                    // Handle vertical resize if needed
                }
            }
        }
    }
    
    // Function to get file icon based on extension
    function getFileIcon(extension) {
        var icons = {
            'go': '🐹',
            'js': '📜',
            'jsx': '⚛️',
            'ts': '📘',
            'tsx': '⚛️',
            'py': '🐍',
            'java': '☕',
            'cpp': '⚙️',
            'c': '⚙️',
            'h': '⚙️',
            'hpp': '⚙️',
            'css': '🎨',
            'scss': '🎨',
            'sass': '🎨',
            'html': '🌐',
            'xml': '📄',
            'json': '📋',
            'yaml': '📋',
            'yml': '📋',
            'toml': '📋',
            'md': '📝',
            'txt': '📄',
            'sh': '🔧',
            'bash': '🔧',
            'zsh': '🔧',
            'fish': '🔧',
            'sql': '🗄️',
            'db': '🗄️',
            'sqlite': '🗄️',
            'dockerfile': '🐳',
            'makefile': '🔨',
            'cmake': '🔨',
            'gitignore': '🚫',
            'license': '📄',
            'readme': '📖'
        }
        
        return icons[extension] || '📄'
    }
    
    // Function to set root path
    function setRootPath(path) {
        rootPath = path
        fileSystemModel.rootPath = path
    }
    
    // Function to refresh the tree
    function refresh() {
        fileSystemModel.refresh()
    }
    
    // Function to toggle hidden files
    function toggleHiddenFiles() {
        showHiddenFiles = !showHiddenFiles
        fileSystemModel.showHiddenFiles = showHiddenFiles
    }
    
    // Component initialization
    Component.onCompleted: {
        // Set default root path
        if (!rootPath) {
            rootPath = AppController.getCurrentWorkingDirectory()
            fileSystemModel.rootPath = rootPath
        }
        
        // Expand root by default
        if (fileTree.model.rowCount() > 0) {
            fileTree.expand(fileTree.model.index(0, 0))
        }
    }
}