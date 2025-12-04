import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: tabBar
    
    // Properties
    property var tabs: []
    property int activeTab: 0
    property int tabHeight: 35
    property int tabWidth: 180
    property int tabSpacing: 1
    
    // Signals
    signal tabSelected(int index)
    signal tabClosed(int index)
    signal tabReordered(int fromIndex, int toIndex)
    
    // Custom properties for drag reordering
    property int dragStartIndex: -1
    property int dragCurrentIndex: -1
    property real dragOffset: 0
    property bool isDragging: false
    
    // Background
    color: Theme.tabBarBackgroundColor
    
    // Tab list
    ListView {
        id: tabList
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        
        orientation: ListView.Horizontal
        spacing: tabSpacing
        interactive: false
        clip: true
        
        // Tab delegate
        delegate: Rectangle {
            id: tabItem
            width: tabWidth
            height: tabHeight
            color: {
                if (index === activeTab) return Theme.tabActiveBackgroundColor
                else if (index === dragCurrentIndex && isDragging) return Theme.tabDragBackgroundColor
                else return Theme.tabInactiveBackgroundColor
            }
            
            // Border
            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: 1
                color: index === activeTab ? Theme.tabActiveBorderColor : Theme.tabInactiveBorderColor
            }
            
            // Tab content
            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: 12
                    rightMargin: 8
                }
                spacing: 8
                
                // File icon
                Rectangle {
                    width: 16
                    height: 16
                    color: {
                        if (model.modified) return Theme.tabModifiedIconColor
                        else return Theme.tabIconColor
                    }
                    radius: 2
                    
                    Text {
                        anchors.centerIn: parent
                        text: model.fileType || "txt"
                        color: parent.color
                        font.pixelSize: 8
                        font.bold: true
                    }
                }
                
                // File name
                Text {
                    text: model.title
                    color: {
                        if (index === activeTab) return Theme.tabActiveTextColor
                        else return Theme.tabInactiveTextColor
                    }
                    font {
                        family: Theme.editorFontFamily
                        pixelSize: 13
                        weight: index === activeTab ? Font.Medium : Font.Normal
                    }
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                }
                
                // Close button
                Rectangle {
                    id: closeButton
                    width: 16
                    height: 16
                    color: "transparent"
                    radius: 8
                    
                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: {
                            if (closeButton.hovered) return Theme.tabCloseButtonHoverColor
                            else return Theme.tabCloseButtonColor
                        }
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: closeButton.color = Theme.tabCloseButtonHoverBackground
                        onExited: closeButton.color = "transparent"
                        onClicked: {
                            mouse.accepted = true
                            tabBar.tabClosed(index)
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }
                }
            }
            
            // Drag handle
            MouseArea {
                id: dragArea
                anchors.fill: parent
                
                property real startX: 0
                property real startY: 0
                
                onPressed: {
                    startX = mouse.x
                    startY = mouse.y
                    
                    // Select tab on click
                    if (mouse.button === Qt.LeftButton) {
                        tabBar.tabSelected(index)
                    }
                }
                
                onPositionChanged: {
                    if (pressed && !isDragging) {
                        var distance = Math.sqrt(Math.pow(mouse.x - startX, 2) + Math.pow(mouse.y - startY, 2))
                        if (distance > 10) {
                            isDragging = true
                            dragStartIndex = index
                            dragCurrentIndex = index
                            tabItem.z = 1000
                        }
                    }
                    
                    if (isDragging) {
                        dragOffset = mouse.x - startX
                        
                        // Calculate new position
                        var newIndex = Math.round((tabItem.x + dragOffset) / (tabWidth + tabSpacing))
                        newIndex = Math.max(0, Math.min(newIndex, tabs.length - 1))
                        
                        if (newIndex !== dragCurrentIndex) {
                            dragCurrentIndex = newIndex
                        }
                    }
                }
                
                onReleased: {
                    if (isDragging) {
                        isDragging = false
                        
                        if (dragCurrentIndex !== dragStartIndex) {
                            tabBar.tabReordered(dragStartIndex, dragCurrentIndex)
                        }
                        
                        // Reset drag state
                        dragStartIndex = -1
                        dragCurrentIndex = -1
                        dragOffset = 0
                        tabItem.z = 0
                    }
                }
            }
            
            // Visual feedback for drag
            states: [
                State {
                    name: "dragging"
                    when: isDragging && index === dragStartIndex
                    PropertyChanges {
                        target: tabItem
                        x: tabItem.x + dragOffset
                        opacity: 0.8
                        scale: 1.05
                    }
                }
            ]
            
            transitions: [
                Transition {
                    from: ""
                    to: "dragging"
                    NumberAnimation {
                        properties: "opacity,scale"
                        duration: 150
                    }
                },
                Transition {
                    from: "dragging"
                    to: ""
                    NumberAnimation {
                        properties: "x,opacity,scale"
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            ]
            
            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }
        }
    }
    
    // New tab button
    Rectangle {
        id: newTabButton
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: 35
        color: Theme.tabNewButtonBackgroundColor
        
        Text {
            anchors.centerIn: parent
            text: "＋"
            color: Theme.tabNewButtonColor
            font.pixelSize: 16
            font.bold: true
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: newTabButton.color = Theme.tabNewButtonHoverBackgroundColor
            onExited: newTabButton.color = Theme.tabNewButtonBackgroundColor
            onClicked: AppController.newTab()
        }
        
        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }
    
    // Function to add a new tab
    function addTab(title, filePath, fileType, modified) {
        var newTab = {
            title: title,
            filePath: filePath,
            fileType: fileType,
            modified: modified || false
        }
        
        tabs.push(newTab)
        tabList.model = tabs
    }
    
    // Function to remove a tab
    function removeTab(index) {
        if (index >= 0 && index < tabs.length) {
            tabs.splice(index, 1)
            tabList.model = tabs
            
            // Adjust active tab
            if (activeTab >= tabs.length) {
                activeTab = tabs.length - 1
            }
            if (activeTab < 0 && tabs.length > 0) {
                activeTab = 0
            }
        }
    }
    
    // Function to update tab title
    function updateTabTitle(index, title) {
        if (index >= 0 && index < tabs.length) {
            tabs[index].title = title
            tabList.model = tabs
        }
    }
    
    // Function to set modified state
    function setTabModified(index, modified) {
        if (index >= 0 && index < tabs.length) {
            tabs[index].modified = modified
            tabList.model = tabs
        }
    }
    
    // Component initialization
    Component.onCompleted: {
        // Set up model
        tabList.model = tabs
    }
}