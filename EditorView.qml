import QtQuick 2.15
import QtQuick.Controls 2.15
import LimeEditor 1.0

Item {
    id: editorViewRoot

    property alias dummyText: editorView.dummyText
    property int lineCount: editorView.lineCount()
    property var cursorPosition: Qt.point(editorView.cursorPosition.x, editorView.cursorPosition.y)

    signal textChanged()
    signal cursorPositionChanged()

    EditorView {
        id: editorView
        objectName: "editorView"
        anchors.fill: parent
        focus: true

        onTextChanged: editorViewRoot.textChanged()
        onCursorPositionChanged: editorViewRoot.cursorPositionChanged()
    }

    // Keyboard shortcuts
    Shortcut {
        sequence: "Ctrl+S"
        onActivated: console.log("Save file")
    }

    Shortcut {
        sequence: "Ctrl+O"
        onActivated: console.log("Open file")
    }

    Shortcut {
        sequence: "Ctrl+N"
        onActivated: console.log("New file")
    }

    Shortcut {
        sequence: "Ctrl+F"
        onActivated: console.log("Find")
    }

    Shortcut {
        sequence: "Ctrl+H"
        onActivated: console.log("Replace")
    }

    // Mouse area for focus
    MouseArea {
        anchors.fill: parent
        onClicked: {
            editorView.forceActiveFocus()
        }
    }

    // Scroll bars
    ScrollBar {
        id: verticalScrollBar
        active: editorViewRoot.height < editorView.implicitHeight
        orientation: Qt.Vertical
        size: editorViewRoot.height / editorView.implicitHeight
        position: editorViewRoot.y / editorView.implicitHeight
        anchors {
            top: parent.top
            right: parent.right
            bottom: horizontalScrollBar.top
        }
        onPositionChanged: {
            editorViewRoot.y = -position * editorView.implicitHeight
        }
    }

    ScrollBar {
        id: horizontalScrollBar
        active: editorViewRoot.width < editorView.implicitWidth
        orientation: Qt.Horizontal
        size: editorViewRoot.width / editorView.implicitWidth
        position: -editorViewRoot.x / editorView.implicitWidth
        anchors {
            left: parent.left
            right: verticalScrollBar.left
            bottom: parent.bottom
        }
        onPositionChanged: {
            editorViewRoot.x = -position * editorView.implicitWidth
        }
    }
}