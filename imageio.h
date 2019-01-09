#ifndef IMAGEIO_H
#define IMAGEIO_H

#include <QString>
#include <QObject>


#ifdef Q_OS_ANDROID
#include <QAndroidActivityResultReceiver>
#endif

class ImageIO;

#ifdef Q_OS_ANDROID
class ImageIOReceiver : public QAndroidActivityResultReceiver {
public:
    ImageIOReceiver(ImageIO* parent):_parent(parent) {}
    void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data);

private:
    ImageIO* _parent;
};
#endif

class ImageIO : public QObject
{
    Q_OBJECT
public:
    explicit ImageIO(QObject *parent = nullptr);

    Q_INVOKABLE void shareImage(const QString& path);

    Q_INVOKABLE bool getImage();

    QString capturedImagePath;

private:

#ifdef Q_OS_ANDROID
    ImageIOReceiver imageIOReceiver;

#endif

signals:
    void imageCaptured(QString path);
};


#endif // IMAGEIO_H
