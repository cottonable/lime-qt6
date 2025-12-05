import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: "Lime Editor"
    color: "#2b2b2b"

    // Menu bar
    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("New")
                shortcut: "Ctrl+N"
                onTriggered: console.log("New file")
            }
            MenuItem {
                text: qsTr("Open...")
                shortcut: "Ctrl+O"
                onTriggered: console.log("Open file")
            }
            MenuItem {
                text: qsTr("Save")
                shortcut: "Ctrl+S"
                onTriggered: console.log("Save file")
            }
            MenuItem {
                text: qsTr("Save As...")
                shortcut: "Ctrl+Shift+S"
                onTriggered: console.log("Save as")
            }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit()
            }
        }

        Menu {
            title: qsTr("Edit")
            MenuItem {
                text: qsTr("Undo")
                shortcut: "Ctrl+Z"
                onTriggered: console.log("Undo")
            }
            MenuItem {
                text: qsTr("Redo")
                shortcut: "Ctrl+Y"
                onTriggered: console.log("Redo")
            }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Cut")
                shortcut: "Ctrl+X"
                onTriggered: console.log("Cut")
            }
            MenuItem {
                text: qsTr("Copy")
                shortcut: "Ctrl+C"
                onTriggered: console.log("Copy")
            }
            MenuItem {
                text: qsTr("Paste")
                shortcut: "Ctrl+V"
                onTriggered: console.log("Paste")
            }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Find...")
                shortcut: "Ctrl+F"
                onTriggered: console.log("Find")
            }
            MenuItem {
                text: qsTr("Replace...")
                shortcut: "Ctrl+H"
                onTriggered: console.log("Replace")
            }
        }

        Menu {
            title: qsTr("View")
            MenuItem {
                text: qsTr("Zoom In")
                shortcut: "Ctrl++"
                onTriggered: console.log("Zoom in")
            }
            MenuItem {
                text: qsTr("Zoom Out")
                shortcut: "Ctrl+-"
                onTriggered: console.log("Zoom out")
            }
            MenuItem {
                text: qsTr("Reset Zoom")
                shortcut: "Ctrl+0"
                onTriggered: console.log("Reset zoom")
            }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Toggle Sidebar")
                onTriggered: sidebar.visible = !sidebar.visible
            }
        }

        Menu {
            title: qsTr("Tools")
            MenuItem {
                text: qsTr("Preferences...")
                onTriggered: console.log("Open preferences")
            }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Command Palette...")
                shortcut: "Ctrl+Shift+P"
                onTriggered: console.log("Open command palette")
            }
        }

        Menu {
            title: qsTr("Help")
            MenuItem {
                text: qsTr("About")
                onTriggered: console.log("About Lime Editor")
            }
        }
    }

    // Main layout
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        Rectangle {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            color: "#1e1e1e"
            visible: true

            ColumnLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                anchors.margins: 10
                spacing: 10

                // File explorer header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Label {
                        text: "Explorer"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#cccccc"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "..."
                        onClicked: console.log("More options")
                    }
                }

                // File tree (placeholder)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#252526"
                    radius: 4

                    Label {
                        anchors.centerIn: parent
                        text: "File Explorer\n(Coming Soon)"
                        color: "#888888"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        // Main editor area
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#2b2b2b"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Tabs area
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    color: "#1e1e1e"

                    RowLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                        }
                        anchors.margins: 5
                        spacing: 5

                        // Tab
                        Rectangle {
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 30
                            color: "#2b2b2b"
                            radius: 4

                            RowLayout {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    bottom: parent.bottom
                                }
                                anchors.margins: 5

                                Label {
                                    text: "untitled.txt"
                                    color: "#cccccc"
                                    font.pixelSize: 12
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Button {
                                    text: "×"
                                    onClicked: console.log("Close tab")
                                }
                            }
                        }

                        // New tab button
                        Button {
                            text: "+"
                            onClicked: console.log("New tab")
                        }
                    }
                }

                // Editor content
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#2b2b2b"

                    EditorView {
                        id: editorView
                        anchors.fill: parent
                        anchors.margins: 10
                        dummyText: "Line 1: Welcome to Lime Editor - A modern text editor\n" +
                                  "Line 2: Built with Qt6 and C++ for high performance\n" +
                                  "Line 3: Features syntax highlighting and code completion\n" +
                                  "Line 4: Multiple cursor support for efficient editing\n" +
                                  "Line 5: Integrated file explorer and project management\n" +
                                  "Line 6: Customizable themes and keyboard shortcuts\n" +
                                  "Line 7: Git integration for version control\n" +
                                  "Line 8: Plugin system for extensibility\n" +
                                  "Line 9: Fast and responsive user interface\n" +
                                  "Line 10: Cross-platform compatibility"

                        onTextChanged: {
                            console.log("Text content changed")
                        }

                        onCursorPositionChanged: {
                            statusBar.cursorLabel.text = "Ln " + (cursorPosition.y + 1) + ", Col " + (cursorPosition.x + 1)
                        }
                    }
                }

                // Status bar
                Rectangle {
                    id: statusBar
                    Layout.fillWidth: true
                    Layout.preferredHeight: 25
                    color: "#007acc"

                    RowLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                        }
                        anchors.margins: 2

                        Label {
                            id: cursorLabel
                            text: "Ln 1, Col 1"
                            color: "white"
                            font.pixelSize: 12
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "UTF-8"
                            color: "white"
                            font.pixelSize: 12
                        }

                        Label {
                            text: "Plain Text"
                            color: "white"
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }

    // Welcome the user
    Component.onCompleted: {
        console.log("Lime Editor started successfully!")
        console.log("Features: Qt6, QML, C++, Syntax highlighting ready")
    }
}