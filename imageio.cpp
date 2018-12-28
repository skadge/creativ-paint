#include "imageio.h"

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#include <QAndroidJniObject>
#include <QAndroidIntent>
#endif


ImageIO::ImageIO(QObject *parent) : QObject(parent)
{

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

#ifdef Q_OS_ANDROID
void ImageIOReceiver::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data)
{
    jint RESULT_OK = QAndroidJniObject::getStaticField<jint>("android/app/Activity", "RESULT_OK");
    if (receiverRequestCode == 101 && resultCode == RESULT_OK)
    {
        qDebug("Success!");
        //QAndroidJniObject uri = data.callObjectMethod("getData", "()Landroid/net/Uri;");
        //QAndroidJniObject dadosAndroid = QAndroidJniObject::getStaticObjectField("android/provider/MediaStore$MediaColumns", "DATA", "Ljava/lang/String;");
        //QAndroidJniEnvironment env;
        //jobjectArray projecao = (jobjectArray)env->NewObjectArray(1, env->FindClass("java/lang/String"), NULL);
        //jobject projacaoDadosAndroid = env->NewStringUTF(dadosAndroid.toString().toStdString().c_str());
        //env->SetObjectArrayElement(projecao, 0, projacaoDadosAndroid);
        //QAndroidJniObject contentResolver = QtAndroid::androidActivity().callObjectMethod("getContentResolver", "()Landroid/content/ContentResolver;");
        //QAndroidJniObject cursor = contentResolver.callObjectMethod("query", "(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;", uri.object<jobject>(), projecao, NULL, NULL, NULL);
        //jint columnIndex = cursor.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", dadosAndroid.object<jstring>());
        //cursor.callMethod<jboolean>("moveToFirst", "()Z");
        //QAndroidJniObject resultado = cursor.callObjectMethod("getString", "(I)Ljava/lang/String;", columnIndex);
        //QString imagemCaminho = "file://" + resultado.toString();
        //emit imagemCaminhoSignal(imagemCaminho);
    }
    else
    {
        qDebug("Error!");
    }
}
#endif
