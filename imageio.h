#ifndef IMAGEIO_H
#define IMAGEIO_H

#include <QString>
#include <QObject>


#ifdef Q_OS_ANDROID
#include <QAndroidActivityResultReceiver>
#endif

#ifdef Q_OS_ANDROID
class ImageIOReceiver : public QAndroidActivityResultReceiver {
    void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data);
};
#endif

class ImageIO : public QObject
{
    Q_OBJECT
public:
    explicit ImageIO(QObject *parent = nullptr);

    Q_INVOKABLE void shareImage(const QString& path);

private:

#ifdef Q_OS_ANDROID
    ImageIOReceiver imageIOReceiver;
#endif

signals:

public slots:
};


#endif // IMAGEIO_H
