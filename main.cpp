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
    qmlRegisterType<FloodFill>("ImageProcessing", 1, 0, "FloodFill");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
