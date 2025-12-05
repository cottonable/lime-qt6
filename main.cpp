#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSurfaceFormat>
#include "editorview.h"

int main(int argc, char *argv[])
{
    // Set up the application
    QGuiApplication app(argc, argv);
    app.setApplicationDisplayName("Lime Editor");
    app.setOrganizationName("Cottonable");
    app.setOrganizationDomain("cottonable.com");

    // Configure OpenGL for better performance
    QSurfaceFormat format;
    format.setDepthBufferSize(24);
    format.setStencilBufferSize(8);
    format.setVersion(3, 3);
    format.setProfile(QSurfaceFormat::CoreProfile);
    QSurfaceFormat::setDefaultFormat(format);

    // Create QML engine
    QQmlApplicationEngine engine;

    // Register custom QML types
    qmlRegisterType<EditorView>("LimeEditor", 1, 0, "EditorView");

    // Load QML from embedded resources
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    // Check if loading was successful
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    // Run the application
    return app.exec();
}