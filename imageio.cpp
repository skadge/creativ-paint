#include "imageio.h"

#include <QDir>
#include <QStandardPaths>

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#include <QAndroidJniObject>
#include <QAndroidIntent>

const int GET_IMAGE_REQUEST_CODE = 1;
const int CAPTURE_CAMERA_REQUEST_CODE = 2;

#endif


ImageIO::ImageIO(QObject *parent) : QObject(parent),
                                    imageIOReceiver(this)
{
        auto dir = QDir(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation));
        capturedImagePath = dir.absoluteFilePath("touchpaint-capture.jpg");

}

void ImageIO::shareImage(const QString& path)
{
#ifdef Q_OS_ANDROID

        QAndroidJniObject jPath = QAndroidJniObject::fromString(path);
        QAndroidJniObject activity = QtAndroid::androidActivity();

        QAndroidJniObject::callStaticMethod<void>(
            "org/guakamole/shareimage/ShareImage",
            "shareImage",
            "(Ljava/lang/String;Lorg/qtproject/qt5/android/bindings/QtActivity;)V",
            jPath.object<jstring>(),
            activity.object<jobject>()
       );
#else
        qDebug("Sharing image!");
#endif
}

bool ImageIO::getImage()
{
#ifdef Q_OS_ANDROID
    //QAndroidJniObject ACTION_GET_CONTENT = QAndroidJniObject::fromString("android.intent.action.GET_CONTENT");
    QAndroidJniObject ACTION_IMAGE_CAPTURE = QAndroidJniObject::fromString("android.media.action.IMAGE_CAPTURE");
    QAndroidJniObject EXTRA_OUTPUT = QAndroidJniObject::fromString("output");
    //QAndroidJniObject CATEGORY_OPENABLE = QAndroidJniObject::fromString("android.intent.category.OPENABLE");



    QAndroidJniObject intent("android/content/Intent");
    if (intent.isValid()) {
        intent.callObjectMethod("setAction", "(Ljava/lang/String;)Landroid/content/Intent;", ACTION_IMAGE_CAPTURE.object<jstring>());
        //intent.callObjectMethod("setAction", "(Ljava/lang/String;)Landroid/content/Intent;", ACTION_GET_CONTENT.object<jstring>());
        //intent.callObjectMethod("setType", "(Ljava/lang/String;)Landroid/content/Intent;", QAndroidJniObject::fromString("*/*").object<jstring>());
        //intent.callObjectMethod("addCategory", "(Ljava/lang/String;)Landroid/content/Intent;", CATEGORY_OPENABLE.object<jstring>());


        QAndroidJniObject jnipath = QAndroidJniObject::fromString("file://" + capturedImagePath);
        QAndroidJniObject uri = QAndroidJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", jnipath.object<jstring>());

        intent.callObjectMethod("putExtra", "(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;",
                                            EXTRA_OUTPUT.object<jstring>(),
                                            uri.object<jobject>());

        /*
        auto chooserIntent = QAndroidJniObject::callStaticObjectMethod("android/content/Intent",
                                                                       "createChooser",
                                                                       "(Landroid/content/Intent;Ljava/lang/CharSequence;)Landroid/content/Intent;",
                                                                       intent.object(),
                                                                       QAndroidJniObject::fromString(QString("Choose an image...")).object());
        QtAndroid::startActivity(chooserIntent.object<jobject>(), GET_IMAGE_REQUEST_CODE, &imageIOReceiver);
        */
        QtAndroid::startActivity(intent.object<jobject>(), CAPTURE_CAMERA_REQUEST_CODE, &imageIOReceiver);
        return true;
    } else {
        return false;
    }

#else
        qDebug("Sharing image!");
#endif
}

#ifdef Q_OS_ANDROID
void ImageIOReceiver::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data)
{
    jint RESULT_OK = QAndroidJniObject::getStaticField<jint>("android/app/Activity", "RESULT_OK");
    if (receiverRequestCode == CAPTURE_CAMERA_REQUEST_CODE) {
        if(resultCode == RESULT_OK)
        {
            emit _parent->imageCaptured(_parent->capturedImagePath);
        }
        else
        {
            qDebug((QString("Error camera capture -- resultCode: ") + resultCode).toStdString().c_str());
        }
    }
    else {
        qDebug("Got unexpected receiverRequestCode...!");
    }
}
#endif
