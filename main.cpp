#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QObject>
#include <QtDebug>

#include "imageio.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<ImageIO>("org.skadge.imageio", 1, 0, "ImageIO");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
