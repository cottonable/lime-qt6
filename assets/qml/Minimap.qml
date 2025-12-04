import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: minimap
    
    // Properties
    property var editorView: null
    property real scaleFactor: 0.15
    property int minimapLineHeight: 2
    property color backgroundColor: Theme.minimapBackgroundColor
    property color textColor: Theme.minimapTextColor
    property color viewportColor: Theme.minimapViewportColor
    property color viewportBorderColor: Theme.minimapViewportBorderColor
    
    // Signals
    signal scrollToLine(int line)
    
    // Custom properties
    property var textLines: []
    property int totalLines: 0
    property real viewportY: 0
    property real viewportHeight: 0
    property bool isDragging: false
    
    // Background
    Rectangle {
        anchors.fill: parent
        color: backgroundColor
    }
    
    // Minimap content
    Flickable {
        id: minimapFlickable
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 4
        }
        
        contentWidth: width
        contentHeight: totalLines * minimapLineHeight
        interactive: false
        
        // Minimap canvas
        Canvas {
            id: minimapCanvas
            anchors.fill: parent
            
            property var lines: textLines
            property real viewportStart: viewportY
            property real viewportEnd: viewportY + viewportHeight
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                // Set font for minimap text
                ctx.font = "1px " + Theme.editorFontFamily
                ctx.fillStyle = textColor
                
                // Draw text lines
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i]
                    var y = i * minimapLineHeight
                    
                    // Skip lines outside viewport
                    if (y + minimapLineHeight < 0 || y > height) {
                        continue
                    }
                    
                    // Draw line text (simplified for performance)
                    if (line && line.length > 0) {
                        var displayText = line.substring(0, Math.min(line.length, 50))
                        ctx.fillText(displayText, 2, y + minimapLineHeight - 1)
                    }
                }
                
                // Draw viewport indicator
                if (viewportHeight > 0) {
                    ctx.fillStyle = viewportColor
                    ctx.fillRect(0, viewportStart, width, viewportHeight)
                    
                    // Draw viewport border
                    ctx.strokeStyle = viewportBorderColor
                    ctx.lineWidth = 1
                    ctx.strokeRect(0, viewportStart, width, viewportHeight)
                }
            }
            
            // Update when properties change
            onLinesChanged: requestPaint()
            onViewportStartChanged: requestPaint()
            onViewportEndChanged: requestPaint()
        }
        
        // Mouse interaction for scrolling
        MouseArea {
            anchors.fill: parent
            
            onPressed: {
                isDragging = true
                var line = Math.floor(mouse.y / minimapLineHeight)
                scrollToLine(line)
            }
            
            onPositionChanged: {
                if (isDragging) {
                    var line = Math.floor(mouse.y / minimapLineHeight)
                    scrollToLine(line)
                }
            }
            
            onReleased: {
                isDragging = false
            }
            
            onWheel: {
                wheel.accepted = true
                // Pass wheel events to editor view
                if (editorView) {
                    editorView.flickable.contentY -= wheel.angleDelta.y * 2
                }
            }
        }
    }
    
    // Scroll bar for minimap
    ScrollBar.vertical: ScrollBar {
        id: minimapScrollBar
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        width: 6
        policy: ScrollBar.AlwaysOn
        
        background: Rectangle {
            color: "transparent"
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
    
    // Function to update minimap content
    function updateContent() {
        if (!editorView || !editorView.backendView) {
            return
        }
        
        // Get text from editor view
        var text = editorView.backendView.text
        if (text) {
            textLines = text.split('\n')
            totalLines = textLines.length
        } else {
            textLines = []
            totalLines = 0
        }
        
        // Update viewport
        updateViewport()
        
        // Trigger canvas repaint
        minimapCanvas.lines = textLines
        minimapCanvas.requestPaint()
    }
    
    // Function to update viewport
    function updateViewport() {
        if (!editorView || !editorView.backendView) {
            return
        }
        
        var editorHeight = editorView.height
        var lineHeight = editorView.backendView.lineHeight
        var scrollPosition = editorView.scrollPosition
        var visibleLines = Math.ceil(editorHeight / lineHeight)
        var firstVisibleLine = Math.floor(scrollPosition / lineHeight)
        
        // Calculate viewport dimensions
        viewportY = firstVisibleLine * minimapLineHeight
        viewportHeight = visibleLines * minimapLineHeight
        
        // Update canvas properties
        minimapCanvas.viewportStart = viewportY
        minimapCanvas.viewportEnd = viewportY + viewportHeight
    }
    
    // Component initialization
    Component.onCompleted: {
        // Set up connections to editor view
        if (editorView) {
            editorView.backendView.onTextChanged.connect(updateContent)
            editorView.onScrollPositionChanged.connect(updateViewport)
            editorView.onHeightChanged.connect(updateViewport)
        }
        
        // Initial update
        updateContent()
    }
    
    // Component destruction
    Component.onDestruction: {
        // Clean up connections
        if (editorView && editorView.backendView) {
            editorView.backendView.onTextChanged.disconnect(updateContent)
            editorView.onScrollPositionChanged.disconnect(updateViewport)
            editorView.onHeightChanged.disconnect(updateViewport)
        }
    }
}