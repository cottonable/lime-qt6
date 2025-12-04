import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: statusBar
    
    // Properties
    property string currentFile: ""
    property string fileType: ""
    property int cursorLine: 1
    property int cursorColumn: 1
    property string encoding: "UTF-8"
    property string lineEndings: "LF"
    property bool modified: false
    property string gitBranch: ""
    property string languageMode: "Plain Text"
    property real zoomLevel: 100
    
    // Signals
    signal toggleSidebar()
    signal toggleTerminal()
    signal toggleMinimap()
    
    // Background
    color: Theme.statusBarBackgroundColor
    
    // Layout
    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: 8
            rightMargin: 8
        }
        spacing: 0
        
        // Left side - File info and tools
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            // Branch indicator
            Rectangle {
                visible: gitBranch !== ""
                height: 20
                color: Theme.statusBarGitBackgroundColor
                radius: 10
                border.color: Theme.statusBarGitBorderColor
                border.width: 1
                
                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                        leftMargin: 8
                        rightMargin: 8
                    }
                    spacing: 4
                    
                    // Git icon
                    Text {
                        text: "🌿"
                        font.pixelSize: 12
                    }
                    
                    // Branch name
                    Text {
                        text: gitBranch
                        color: Theme.statusBarGitTextColor
                        font {
                            family: Theme.editorFontFamily
                            pixelSize: 11
                            weight: Font.Medium
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: AppController.showGitPanel()
                }
            }
            
            // File info
            Rectangle {
                height: 20
                color: Theme.statusBarFileInfoBackgroundColor
                radius: 10
                border.color: Theme.statusBarFileInfoBorderColor
                border.width: 1
                
                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                        leftMargin: 8
                        rightMargin: 8
                    }
                    spacing: 6
                    
                    // File type icon
                    Text {
                        text: getFileTypeIcon(fileType)
                        font.pixelSize: 12
                    }
                    
                    // File name
                    Text {
                        text: {
                            var name = currentFile ? currentFile.split('/').pop() : "Untitled"
                            return modified ? name + " ●" : name
                        }
                        color: Theme.statusBarFileInfoTextColor
                        font {
                            family: Theme.editorFontFamily
                            pixelSize: 11
                        }
                    }
                    
                    // Encoding
                    Text {
                        text: encoding
                        color: Theme.statusBarFileInfoTextColor
                        font {
                            family: Theme.editorFontFamily
                            pixelSize: 10
                        }
                        opacity: 0.7
                    }
                    
                    // Line endings
                    Text {
                        text: lineEndings
                        color: Theme.statusBarFileInfoTextColor
                        font {
                            family: Theme.editorFontFamily
                            pixelSize: 10
                        }
                        opacity: 0.7
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: AppController.showFileInfo()
                }
            }
        }
        
        // Center - Cursor position and language
        RowLayout {
            spacing: 8
            
            // Cursor position
            Rectangle {
                height: 20
                color: Theme.statusBarCursorBackgroundColor
                radius: 10
                border.color: Theme.statusBarCursorBorderColor
                border.width: 1
                
                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                        leftMargin: 8
                        rightMargin: 8
                    }
                    spacing: 4
                    
                    // Line:Column
                    Text {
                        text: "Ln " + cursorLine + ", Col " + cursorColumn
                        color: Theme.statusBarCursorTextColor
                        font {
                            family: Theme.editorFontFamily
                            pixelSize: 11
                        }
                    }
                    
                    // Selection info
                    Text {
                        visible: AppController.hasSelection
                        text: "(" + AppController.selectionLines + " lines)"
                        color: Theme.statusBarCursorTextColor
                        font {
                            family: Theme.editorFontFamily
                            pixelSize: 10
                        }
                        opacity: 0.7
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: AppController.showGoToLineDialog()
                }
            }
            
            // Language mode
            Rectangle {
                height: 20
                color: Theme.statusBarLanguageBackgroundColor
                radius: 10
                border.color: Theme.statusBarLanguageBorderColor
                border.width: 1
                
                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                        leftMargin: 8
                        rightMargin: 8
                    }
                    spacing: 4
                    
                    Text {
                        text: languageMode
                        color: Theme.statusBarLanguageTextColor
                        font {
                            family: Theme.editorFontFamily
                            pixelSize: 11
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: AppController.showLanguageSelector()
                }
            }
            
            // Zoom level
            Rectangle {
                visible: zoomLevel !== 100
                height: 20
                color: Theme.statusBarZoomBackgroundColor
                radius: 10
                border.color: Theme.statusBarZoomBorderColor
                border.width: 1
                
                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                        leftMargin: 8
                        rightMargin: 8
                    }
                    spacing: 4
                    
                    Text {
                        text: Math.round(zoomLevel) + "%"
                        color: Theme.statusBarZoomTextColor
                        font {
                            family: Theme.editorFontFamily
                            pixelSize: 11
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: AppController.resetZoom()
                }
            }
        }
        
        // Right side - Tools and toggles
        RowLayout {
            spacing: 4
            
            // Notification area
            Rectangle {
                id: notificationArea
                height: 20
                color: Theme.statusBarNotificationBackgroundColor
                radius: 10
                border.color: Theme.statusBarNotificationBorderColor
                border.width: 1
                visible: AppController.hasNotifications
                
                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                        leftMargin: 8
                        rightMargin: 8
                    }
                    spacing: 4
                    
                    Text {
                        text: "🔔"
                        font.pixelSize: 12
                    }
                    
                    Text {
                        text: AppController.notificationCount.toString()
                        color: Theme.statusBarNotificationTextColor
                        font {
                            family: Theme.editorFontFamily
                            pixelSize: 11
                            weight: Font.Medium
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: AppController.showNotifications()
                }
            }
            
            // Toggle buttons
            Rectangle {
                id: sidebarToggle
                width: 24
                height: 24
                color: Theme.statusBarToggleBackgroundColor
                radius: 12
                border.color: AppController.sidebarVisible ? 
                    Theme.statusBarToggleActiveBorderColor : 
                    Theme.statusBarToggleBorderColor
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "📁"
                    font.pixelSize: 12
                    opacity: AppController.sidebarVisible ? 1.0 : 0.6
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: toggleSidebar()
                }
                
                Behavior on border.color {
                    ColorAnimation {
                        duration: 100
                    }
                }
            }
            
            Rectangle {
                id: terminalToggle
                width: 24
                height: 24
                color: Theme.statusBarToggleBackgroundColor
                radius: 12
                border.color: AppController.terminalVisible ? 
                    Theme.statusBarToggleActiveBorderColor : 
                    Theme.statusBarToggleBorderColor
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "⌨"
                    font.pixelSize: 12
                    opacity: AppController.terminalVisible ? 1.0 : 0.6
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: toggleTerminal()
                }
                
                Behavior on border.color {
                    ColorAnimation {
                        duration: 100
                    }
                }
            }
            
            Rectangle {
                id: minimapToggle
                width: 24
                height: 24
                color: Theme.statusBarToggleBackgroundColor
                radius: 12
                border.color: AppController.minimapVisible ? 
                    Theme.statusBarToggleActiveBorderColor : 
                    Theme.statusBarToggleBorderColor
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "🗺"
                    font.pixelSize: 12
                    opacity: AppController.minimapVisible ? 1.0 : 0.6
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: toggleMinimap()
                }
                
                Behavior on border.color {
                    ColorAnimation {
                        duration: 100
                    }
                }
            }
        }
    }
    
    // Function to get file type icon
    function getFileTypeIcon(fileType) {
        var icons = {
            'go': '🐹',
            'javascript': '📜',
            'typescript': '📘',
            'python': '🐍',
            'java': '☕',
            'cpp': '⚙️',
            'c': '⚙️',
            'css': '🎨',
            'html': '🌐',
            'json': '📋',
            'markdown': '📝',
            'text': '📄',
            'shell': '🔧',
            'sql': '🗄️',
            'docker': '🐳',
            'yaml': '📋',
            'xml': '📄'
        }
        return icons[fileType.toLowerCase()] || '📄'
    }
    
    // Function to update status
    function updateStatus(file, type, line, column, enc, lineEnd, mod, branch, lang, zoom) {
        currentFile = file
        fileType = type
        cursorLine = line
        cursorColumn = column
        encoding = enc
        lineEndings = lineEnd
        modified = mod
        gitBranch = branch
        languageMode = lang
        zoomLevel = zoom
    }
}