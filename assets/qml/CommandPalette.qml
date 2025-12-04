import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Rectangle {
    id: commandPalette
    
    // Properties
    property bool isOpen: false
    property var commands: []
    property var filteredCommands: []
    property int selectedIndex: 0
    property string searchText: ""
    
    // Signals
    signal commandSelected(string command)
    signal closed()
    
    // Custom properties
    property var allCommands: [
        { title: "File: Open", category: "File", action: "file.open" },
        { title: "File: Save", category: "File", action: "file.save" },
        { title: "File: Save All", category: "File", action: "file.saveAll" },
        { title: "File: Close", category: "File", action: "file.close" },
        { title: "File: Close All", category: "File", action: "file.closeAll" },
        { title: "File: New File", category: "File", action: "file.new" },
        { title: "Edit: Undo", category: "Edit", action: "edit.undo" },
        { title: "Edit: Redo", category: "Edit", action: "edit.redo" },
        { title: "Edit: Cut", category: "Edit", action: "edit.cut" },
        { title: "Edit: Copy", category: "Edit", action: "edit.copy" },
        { title: "Edit: Paste", category: "Edit", action: "edit.paste" },
        { title: "Edit: Select All", category: "Edit", action: "edit.selectAll" },
        { title: "Edit: Find", category: "Edit", action: "edit.find" },
        { title: "Edit: Find and Replace", category: "Edit", action: "edit.replace" },
        { title: "View: Toggle Sidebar", category: "View", action: "view.toggleSidebar" },
        { title: "View: Toggle Minimap", category: "View", action: "view.toggleMinimap" },
        { title: "View: Toggle Terminal", category: "View", action: "view.toggleTerminal" },
        { title: "View: Zoom In", category: "View", action: "view.zoomIn" },
        { title: "View: Zoom Out", category: "View", action: "view.zoomOut" },
        { title: "View: Reset Zoom", category: "View", action: "view.resetZoom" },
        { title: "Go: Go to File", category: "Go", action: "go.toFile" },
        { title: "Go: Go to Line", category: "Go", action: "go.toLine" },
        { title: "Go: Go to Symbol", category: "Go", action: "go.toSymbol" },
        { title: "Go: Go to Definition", category: "Go", action: "go.toDefinition" },
        { title: "Go: Go to References", category: "Go", action: "go.toReferences" },
        { title: "Go: Back", category: "Go", action: "go.back" },
        { title: "Go: Forward", category: "Go", action: "go.forward" },
        { title: "Tools: Build", category: "Tools", action: "tools.build" },
        { title: "Tools: Run", category: "Tools", action: "tools.run" },
        { title: "Tools: Debug", category: "Tools", action: "tools.debug" },
        { title: "Tools: Test", category: "Tools", action: "tools.test" },
        { title: "Tools: Format Document", category: "Tools", action: "tools.format" },
        { title: "Preferences: Open Settings", category: "Preferences", action: "preferences.openSettings" },
        { title: "Preferences: Open Keyboard Shortcuts", category: "Preferences", action: "preferences.openKeybindings" },
        { title: "Preferences: Select Theme", category: "Preferences", action: "preferences.selectTheme" },
        { title: "Help: Welcome", category: "Help", action: "help.welcome" },
        { title: "Help: Documentation", category: "Help", action: "help.documentation" },
        { title: "Help: Release Notes", category: "Help", action: "help.releaseNotes" },
        { title: "Help: About", category: "Help", action: "help.about" }
    ]
    
    // Background
    color: Theme.commandPaletteBackgroundColor
    radius: 8
    border.color: Theme.commandPaletteBorderColor
    border.width: 1
    opacity: 0
    visible: false
    
    // Drop shadow effect
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 4
        radius: 12
        samples: 16
        color: "#20000000"
    }
    
    // Layout
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // Search input
        Rectangle {
            id: searchContainer
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Theme.commandPaletteSearchBackgroundColor
            radius: 6
            border.color: Theme.commandPaletteSearchBorderColor
            border.width: searchInput.activeFocus ? 2 : 1
            
            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                    rightMargin: 12
                }
                spacing: 8
                
                // Search icon
                Text {
                    text: "🔍"
                    font.pixelSize: 16
                    opacity: 0.6
                }
                
                // Input field
                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: "Search commands..."
                    color: Theme.commandPaletteTextColor
                    font {
                        family: Theme.editorFontFamily
                        pixelSize: 14
                    }
                    selectByMouse: true
                    
                    background: Rectangle {
                        color: "transparent"
                    }
                    
                    onTextChanged: {
                        searchText = text
                        filterCommands()
                    }
                    
                    Keys.onDownPressed: {
                        event.accepted = true
                        selectNext()
                    }
                    
                    Keys.onUpPressed: {
                        event.accepted = true
                        selectPrevious()
                    }
                    
                    Keys.onReturnPressed: {
                        event.accepted = true
                        executeSelected()
                    }
                    
                    Keys.onEscapePressed: {
                        event.accepted = true
                        close()
                    }
                }
            }
        }
        
        // Commands list
        ListView {
            id: commandsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            // Scroll bar
            ScrollBar.vertical: ScrollBar {
                width: 6
                policy: ScrollBar.AsNeeded
                
                background: Rectangle {
                    color: Theme.scrollBarBackgroundColor
                    radius: 3
                }
                
                contentItem: Rectangle {
                    color: Theme.scrollBarHandleColor
                    radius: 3
                    opacity: 0.6
                    
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }
                
                onHoveredChanged: {
                    contentItem.opacity = hovered ? 0.9 : 0.6
                }
            }
            
            // Delegate
            delegate: Rectangle {
                id: commandItem
                width: commandsList.width
                height: 36
                color: {
                    if (index === selectedIndex) return Theme.commandPaletteSelectedBackgroundColor
                    else return Theme.commandPaletteItemBackgroundColor
                }
                
                // Hover effect
                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }
                
                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 12
                        rightMargin: 12
                    }
                    spacing: 12
                    
                    // Category icon
                    Rectangle {
                        width: 20
                        height: 20
                        color: Theme.commandPaletteCategoryColor
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: getCategoryIcon(model.category)
                            font.pixelSize: 10
                        }
                    }
                    
                    // Command title
                    Text {
                        text: model.title
                        color: {
                            if (index === selectedIndex) return Theme.commandPaletteSelectedTextColor
                            else return Theme.commandPaletteTextColor
                        }
                        font {
                            family: Theme.editorFontFamily
                            pixelSize: 13
                            weight: index === selectedIndex ? Font.Medium : Font.Normal
                        }
                        Layout.fillWidth: true
                    }
                    
                    // Keybinding hint
                    Text {
                        text: getKeybinding(model.action)
                        color: Theme.commandPaletteKeybindingColor
                        font {
                            family: Theme.editorFontFamily
                            pixelSize: 11
                        }
                        opacity: 0.6
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        selectedIndex = index
                        executeSelected()
                    }
                    onEntered: {
                        selectedIndex = index
                    }
                }
            }
            
            // Selection handling
            onCurrentIndexChanged: {
                selectedIndex = currentIndex
            }
        }
        
        // Footer
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                text: {
                    if (filteredCommands.length === allCommands.length) {
                        return "↑↓ to navigate • Enter to select • Esc to close"
                    } else {
                        return filteredCommands.length + " of " + allCommands.length + " commands"
                    }
                }
                color: Theme.commandPaletteFooterColor
                font {
                    family: Theme.editorFontFamily
                    pixelSize: 11
                }
                opacity: 0.6
            }
        }
    }
    
    // Function to open command palette
    function open() {
        isOpen = true
        visible = true
        
        // Reset state
        searchText = ""
        selectedIndex = 0
        filteredCommands = allCommands
        
        // Focus search input
        searchInput.forceActiveFocus()
        
        // Animate in
        opacity = 0
        NumberAnimation {
            target: commandPalette
            property: "opacity"
            to: 1
            duration: 200
            easing.type: Easing.OutCubic
        }.start()
    }
    
    // Function to close command palette
    function close() {
        NumberAnimation {
            target: commandPalette
            property: "opacity"
            to: 0
            duration: 150
            easing.type: Easing.InCubic
            onFinished: {
                commandPalette.visible = false
                commandPalette.isOpen = false
                closed()
            }
        }.start()
    }
    
    // Function to filter commands
    function filterCommands() {
        if (!searchText) {
            filteredCommands = allCommands
        } else {
            var query = searchText.toLowerCase()
            filteredCommands = allCommands.filter(function(command) {
                return command.title.toLowerCase().includes(query) ||
                       command.category.toLowerCase().includes(query) ||
                       command.action.toLowerCase().includes(query)
            })
        }
        
        selectedIndex = 0
        commandsList.model = filteredCommands
    }
    
    // Function to select next item
    function selectNext() {
        if (selectedIndex < filteredCommands.length - 1) {
            selectedIndex++
            commandsList.currentIndex = selectedIndex
            commandsList.positionViewAtIndex(selectedIndex, ListView.Contain)
        }
    }
    
    // Function to select previous item
    function selectPrevious() {
        if (selectedIndex > 0) {
            selectedIndex--
            commandsList.currentIndex = selectedIndex
            commandsList.positionViewAtIndex(selectedIndex, ListView.Contain)
        }
    }
    
    // Function to execute selected command
    function executeSelected() {
        if (selectedIndex >= 0 && selectedIndex < filteredCommands.length) {
            var command = filteredCommands[selectedIndex]
            commandSelected(command.action)
            close()
        }
    }
    
    // Function to get category icon
    function getCategoryIcon(category) {
        var icons = {
            "File": "📄",
            "Edit": "✏️",
            "View": "👁️",
            "Go": "🚀",
            "Tools": "🔧",
            "Preferences": "⚙️",
            "Help": "❓"
        }
        return icons[category] || "⚡"
    }
    
    // Function to get keybinding
    function getKeybinding(action) {
        var keybindings = {
            "file.open": "Ctrl+O",
            "file.save": "Ctrl+S",
            "file.saveAll": "Ctrl+Shift+S",
            "file.close": "Ctrl+W",
            "file.new": "Ctrl+N",
            "edit.undo": "Ctrl+Z",
            "edit.redo": "Ctrl+Y",
            "edit.cut": "Ctrl+X",
            "edit.copy": "Ctrl+C",
            "edit.paste": "Ctrl+V",
            "edit.selectAll": "Ctrl+A",
            "edit.find": "Ctrl+F",
            "edit.replace": "Ctrl+H",
            "view.toggleSidebar": "Ctrl+B",
            "view.toggleTerminal": "Ctrl+`",
            "view.zoomIn": "Ctrl++",
            "view.zoomOut": "Ctrl+-",
            "view.resetZoom": "Ctrl+0",
            "go.toFile": "Ctrl+P",
            "go.toLine": "Ctrl+G",
            "go.toSymbol": "Ctrl+Shift+O",
            "go.back": "Alt+Left",
            "go.forward": "Alt+Right"
        }
        return keybindings[action] || ""
    }
    
    // Component initialization
    Component.onCompleted: {
        // Initialize with all commands
        filteredCommands = allCommands
        commandsList.model = filteredCommands
    }
    
    // Handle global escape
    Keys.onEscapePressed: {
        if (isOpen) {
            event.accepted = true
            close()
        }
    }
}