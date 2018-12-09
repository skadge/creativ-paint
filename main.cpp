#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QObject>
#include <QtDebug>

#include "imageprocessing.h"

#include "imageio.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<ImageIO>("org.skadge.imageio", 1, 0, "ImageIO");
    qmlRegisterType<InteractiveCanvas>("InteractiveCanvas", 1, 0, "InteractiveCanvas");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
