package main

import (
	"fmt"
	"os"

	"github.com/therecipe/qt/core"
	"github.com/therecipe/qt/gui"
	"github.com/therecipe/qt/qml"
	"github.com/therecipe/qt/quick"
)

// Backend provides data and functionality to QML
type Backend struct {
	core.QObject

	_ func() `constructor:"init"`

	// Properties
	_ string `property:"dummyText"`

	// Methods exposed to QML
	_ func() string `slot:"getDummyText"`
}

func (b *Backend) init() {
	fmt.Println("Backend initialized")
}

func (b *Backend) GetDummyText() string {
	return `Line 1: Welcome to Lime Editor - A modern text editor
Line 2: Built with Qt6 and Go for high performance
Line 3: Features syntax highlighting and code completion
Line 4: Multiple cursor support for efficient editing
Line 5: Integrated file explorer and project management
Line 6: Customizable themes and keyboard shortcuts
Line 7: Git integration for version control
Line 8: Plugin system for extensibility
Line 9: Fast and responsive user interface
Line 10: Cross-platform compatibility`
}

// EditorView is a custom QQuickPaintedItem for text rendering
type EditorView struct {
	quick.QQuickPaintedItem

	_ func() `constructor:"init"`

	// Properties
	_ *Backend `property:"backend"`

	// Signals
	_ func() `signal:"textChanged"`
	_ func() `signal:"cursorPositionChanged"`
}

func (e *EditorView) init() {
	e.ConnectPaint(e.paint)
	e.SetRenderTarget(quick.QQuickPaintedItem__FramebufferObject)
	e.SetAntialiasing(false)
	e.SetFlag(quick.QQuickItem__ItemAcceptsInputMethod, true)
	e.SetFlag(quick.QQuickItem__ItemIsFocusScope, true)
}

func (e *EditorView) paint(painter *gui.QPainter) {
	if e.Backend() == nil {
		return
	}

	// Fill background
	painter.FillRect(e.BoundingRect(), gui.NewQColor3(43, 43, 43, 255))

	// Set up font for crisp rendering
	font := gui.NewQFont2("Consolas, Monaco, monospace", 14, -1, false)
	font.SetStyleHint(gui.QFont__Monospace, gui.QFont__PreferAntialias)
	painter.SetFont(font)

	// Set text color to light gray
	painter.SetPen(gui.NewQPen3(gui.NewQColor3(204, 204, 204, 255)))

	// Get dummy text from backend
	text := e.Backend().GetDummyText()
	lines := splitLines(text)

	// Draw each line with proper spacing
	lineHeight := 20
	margin := 10
	for i, line := range lines {
		if i >= 10 {
			break
		}
		y := margin + (i+1)*lineHeight
		painter.DrawText2(margin, y, line)
	}

	// Draw cursor
	cursorX := margin + 0*8 // Assuming 8px per character
	cursorY := margin + 1*lineHeight
	painter.SetPen(gui.NewQPen3(gui.NewQColor3(0, 122, 204, 255)))
	painter.DrawLine3(cursorX, cursorY-lineHeight, cursorX, cursorY)
}

func splitLines(text string) []string {
	var lines []string
	start := 0
	for i, c := range text {
		if c == '\n' {
			lines = append(lines, text[start:i])
			start = i + 1
		}
	}
	if start < len(text) {
		lines = append(lines, text[start:])
	}
	return lines
}

func main() {
	// Create Qt application
	app := gui.NewQGuiApplication(len(os.Args), os.Args)
	app.SetApplicationDisplayName("Lime Editor")
	app.SetOrganizationName("Cottonable")

	// Create backend
	backend := NewBackend(nil)

	// Register QML types
	qml.RegisterTypes()

	// Create QML engine
	engine := qml.NewQQmlApplicationEngine(nil)

	// Set backend as context property
	engine.RootContext().SetContextProperty("backend", backend)

	// Load QML from embedded resources
	engine.Load(core.NewQUrl3("qrc:/main.qml", core.QUrl__TolerantMode))

	// Check if loading was successful
	if len(engine.RootObjects()) == 0 {
		fmt.Println("Failed to load QML file")
		os.Exit(1)
	}

	// Start application
	if app.Exec() != 0 {
		fmt.Println("Application failed to start")
		os.Exit(1)
	}
}

func init() {
	// Register custom QML types
	qml.RegisterCustomType(
		"EditorView",
		1, 0,
		"EditorView",
		func() interface{} {
			ev := NewEditorView(nil)
			return ev
		},
	)
}