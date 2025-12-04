import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import LimeEditor 1.0

Item {
    id: editorView
    
    // Properties
    property alias text: backendView.text
    property alias cursorPosition: backendView.cursorPosition
    property alias selectionStart: backendView.selectionStart
    property alias selectionEnd: backendView.selectionEnd
    property alias scrollPosition: flickable.contentY
    property alias fontSize: backendView.fontSize
    property alias fontFamily: backendView.fontFamily
    property alias lineHeight: backendView.lineHeight
    property alias theme: backendView.theme
    
    // Signals
    signal textChanged(string text)
    signal cursorPositionChanged(int line, int column)
    signal selectionChanged(int startLine, int endLine)
    signal scrollPositionChanged(real y)
    
    // Custom properties for smooth scrolling
    property real targetScrollY: 0
    property real currentScrollY: 0
    property bool smoothScrolling: true
    property int scrollAnimationDuration: 150
    
    // Backend integration
    EditorItem {
        id: backendView
        anchors.fill: parent
        
        // Rendering properties
        fontSize: Theme.editorFontSize
        fontFamily: Theme.editorFontFamily
        lineHeight: Theme.editorLineHeight
        theme: ThemeManager.currentTheme
        
        // Enable subpixel rendering
        renderType: Text.QtRendering
        renderTypeQuality: Text.Normal
        
        // Smooth scrolling
        smoothScroll: true
        scrollDelta: 0.1
        
        onTextChanged: editorView.textChanged(text)
        onCursorPositionChanged: editorView.cursorPositionChanged(line, column)
        onSelectionChanged: editorView.selectionChanged(startLine, endLine)
        onScrollPositionChanged: editorView.scrollPositionChanged(y)
    }
    
    // Flickable for smooth touch/mouse scrolling
    Flickable {
        id: flickable
        anchors.fill: parent
        
        // Content dimensions
        contentWidth: backendView.contentWidth
        contentHeight: backendView.contentHeight
        
        // Flicking behavior
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.DragAndOvershootBounds
        maximumFlickVelocity: 4000
        flickDeceleration: 3000
        
        // Smooth scrolling animation
        Behavior on contentY {
            enabled: editorView.smoothScrolling
            NumberAnimation {
                duration: editorView.scrollAnimationDuration
                easing.type: Easing.OutCubic
            }
        }
        
        // Mouse wheel handling with smooth scrolling
        MouseArea {
            anchors.fill: parent
            
            property real wheelAccumulator: 0
            property int scrollLines: 3
            
            onWheel: {
                wheel.accepted = true
                
                // Calculate scroll delta
                var delta = wheel.angleDelta.y / 120 * editorView.lineHeight * scrollLines
                wheelAccumulator += delta
                
                // Apply scroll with momentum
                if (Math.abs(wheelAccumulator) >= 1) {
                    var scrollDelta = Math.round(wheelAccumulator)
                    wheelAccumulator -= scrollDelta
                    
                    // Smooth scroll to target
                    editorView.targetScrollY = Math.max(0, 
                        Math.min(flickable.contentHeight - flickable.height,
                            flickable.contentY - scrollDelta))
                    
                    // Animate to target
                    if (editorView.smoothScrolling) {
                        flickable.contentY = editorView.targetScrollY
                    } else {
                        flickable.contentY = editorView.targetScrollY
                    }
                }
            }
            
            onPressed: {
                // Handle middle mouse button scrolling
                if (mouse.button === Qt.MiddleButton) {
                    wheelAccumulator = 0
                    mouse.accepted = true
                }
            }
        }
        
        // Keyboard navigation
        Keys.onUpPressed: {
            event.accepted = true
            backendView.moveCursorUp()
        }
        
        Keys.onDownPressed: {
            event.accepted = true
            backendView.moveCursorDown()
        }
        
        Keys.onLeftPressed: {
            event.accepted = true
            backendView.moveCursorLeft()
        }
        
        Keys.onRightPressed: {
            event.accepted = true
            backendView.moveCursorRight()
        }
        
        Keys.onPageUpPressed: {
            event.accepted = true
            backendView.pageUp()
        }
        
        Keys.onPageDownPressed: {
            event.accepted = true
            backendView.pageDown()
        }
        
        Keys.onHomePressed: {
            event.accepted = true
            backendView.moveToLineStart()
        }
        
        Keys.onEndPressed: {
            event.accepted = true
            backendView.moveToLineEnd()
        }
        
        // Text input handling
        Keys.onPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true
                backendView.insertText("\n")
            } else if (event.key === Qt.Key_Backspace) {
                event.accepted = true
                backendView.backspace()
            } else if (event.key === Qt.Key_Delete) {
                event.accepted = true
                backendView.deleteChar()
            } else if (event.key === Qt.Key_Tab) {
                event.accepted = true
                backendView.insertText("    ")
            } else if (event.text.length > 0) {
                event.accepted = true
                backendView.insertText(event.text)
            }
        }
        
        // Focus handling
        focus: true
        onFocusChanged: {
            if (focus) {
                backendView.setFocus(true)
            }
        }
    }
    
    // Scroll bar
    ScrollBar.vertical: ScrollBar {
        id: verticalScrollBar
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        width: 12
        policy: ScrollBar.AlwaysOn
        
        // Custom styling
        background: Rectangle {
            color: Theme.scrollBarBackgroundColor
            radius: 6
        }
        
        contentItem: Rectangle {
            color: Theme.scrollBarHandleColor
            radius: 6
            
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
        
        // Hover effects
        onHoveredChanged: {
            if (hovered) {
                contentItem.color = Theme.scrollBarHandleHoverColor
            } else {
                contentItem.color = Theme.scrollBarHandleColor
            }
        }
    }
    
    // Horizontal scroll bar
    ScrollBar.horizontal: ScrollBar {
        id: horizontalScrollBar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 12
        policy: ScrollBar.AsNeeded
        
        background: Rectangle {
            color: Theme.scrollBarBackgroundColor
            radius: 6
        }
        
        contentItem: Rectangle {
            color: Theme.scrollBarHandleColor
            radius: 6
            
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }
    
    // Function to scroll to specific line
    function scrollToLine(lineNumber) {
        var lineY = lineNumber * backendView.lineHeight
        var targetY = Math.max(0, lineY - (flickable.height / 2))
        
        if (smoothScrolling) {
            flickable.contentY = targetY
        } else {
            flickable.contentY = targetY
        }
    }
    
    // Function to center on line
    function centerOnLine(lineNumber) {
        var lineY = lineNumber * backendView.lineHeight
        var centerY = lineY - (flickable.height / 2)
        flickable.contentY = Math.max(0, Math.min(centerY, flickable.contentHeight - flickable.height))
    }
    
    // Component initialization
    Component.onCompleted: {
        // Set up smooth scrolling
        backendView.smoothScroll = smoothScrolling
        
        // Connect scroll position updates
        flickable.onContentYChanged: {
            backendView.updateScrollPosition(flickable.contentY)
        }
    }
}