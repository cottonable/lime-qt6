package main

import (
	"os"
	"path/filepath"
	"runtime"

	"github.com/cottonable/lime-qt6/internal/editor"
	"github.com/cottonable/lime-qt6/internal/ui"
	"github.com/sirupsen/logrus"
	"github.com/therecipe/qt/core"
	"github.com/therecipe/qt/gui"
	"github.com/therecipe/qt/qml"
	"github.com/therecipe/qt/quick"
)

func main() {
	// Enable high-DPI support
	core.QCoreApplication_SetAttribute(core.Qt__AA_EnableHighDpiScaling, true)
	core.QCoreApplication_SetAttribute(core.Qt__AA_UseHighDpiPixmaps, true)

	// Create application
	app := gui.NewQGuiApplication(len(os.Args), os.Args)
	app.SetApplicationDisplayName("Lime Editor")
	app.SetApplicationName("lime-qt6")
	app.SetOrganizationName("cottonable")
	app.SetOrganizationDomain("github.com/cottonable")

	// Set up logging
	setupLogging()

	// Register custom QML types
	registerQMLTypes()

	// Create QML engine
	engine := qml.NewQQmlApplicationEngine(nil)

	// Set up QML import paths
	setupQMLImportPaths(engine)

	// Create context properties
	context := engine.RootContext()
	context.SetContextProperty("__appVersion", "1.0.0")
	context.SetContextProperty("__qtVersion", runtime.Version())

	// Create application controller
	appController := ui.NewApplicationController(nil)
	context.SetContextProperty("AppController", appController)

	// Load main QML file
	engine.Load(core.NewQUrl3("qrc:/qml/main.qml", core.QUrl__TolerantMode))

	// Check if main window was created
	if len(engine.RootObjects()) == 0 {
		logrus.Fatal("Failed to load QML file")
	}

	// Start event loop
	gui.QGuiApplication_Exec()
}

func setupLogging() {
	logrus.SetLevel(logrus.DebugLevel)
	logrus.SetFormatter(&logrus.TextFormatter{
		FullTimestamp:   true,
		TimestampFormat: "2006-01-02 15:04:05.000",
	})
}

func registerQMLTypes() {
	// Register custom EditorItem
	qml.RegisterType(
		editor.NewEditorItem,
		"LimeEditor",
		1, 0,
		"EditorItem",
	)

	// Register other custom types
	qml.RegisterType(
		ui.NewFileSystemModel,
		"LimeEditor",
		1, 0,
		"FileSystemModel",
	)

	qml.RegisterSingletonType(
		ui.NewThemeManager,
		"LimeEditor",
		1, 0,
		"ThemeManager",
	)
}

func setupQMLImportPaths(engine *qml.QQmlApplicationEngine) {
	// Add Qt Quick Controls 2 import path
	engine.AddImportPath("qrc:/qt-project.org/imports")
	
	// Add custom import paths for development
	if runtime.GOOS == "windows" {
		// Windows-specific paths
		engine.AddImportPath("C:/Qt/6.8.0/mingw_64/qml")
	} else if runtime.GOOS == "darwin" {
		// macOS-specific paths
		engine.AddImportPath("/usr/local/opt/qt/lib/qml")
		engine.AddImportPath("/opt/homebrew/opt/qt/lib/qml")
	} else {
		// Linux-specific paths
		engine.AddImportPath("/usr/lib/qt6/qml")
		engine.AddImportPath("/usr/lib/x86_64-linux-gnu/qt6/qml")
	}

	// Add local QML development path for hot-reload
	cwd, _ := os.Getwd()
	qmlPath := filepath.Join(cwd, "assets", "qml")
	if _, err := os.Stat(qmlPath); err == nil {
		engine.AddImportPath(qmlPath)
		logrus.Infof("Added development QML path: %s", qmlPath)
	}
}