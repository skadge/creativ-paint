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
    QAndroidJniObject ACTION_GET_CONTENT = QAndroidJniObject::getStaticObjectField<jstring>("android/content/Intent",
                                                                                          "ACTION_GET_CONTENT");
    QAndroidJniObject intent("android/content/Intent",
                             "(Ljava/lang/String;)V",
                             ACTION_GET_CONTENT.object<jstring>());

    QAndroidJniObject EXTRA_LOCAL_ONLY = QAndroidJniObject::getStaticObjectField<jstring>("android/content/Intent",
                                                                                      "EXTRA_LOCAL_ONLY");
    intent.callObjectMethod("putExtra",
                            "(Ljava/lang/String;Z)Landroid/content/Intent;",
                            EXTRA_LOCAL_ONLY.object<jstring>(),
                            jboolean(true));


    //QAndroidJniObject ACTION_SET_TIMER = QAndroidJniObject::getStaticObjectField<jstring>("android/provider/AlarmClock",
    //                                                                                      "ACTION_SET_TIMER");
    //QAndroidJniObject intent("android/content/Intent",
    //                         "(Ljava/lang/String;)V",
    //                         ACTION_SET_TIMER.object<jstring>());

    //QAndroidJniObject EXTRA_MESSAGE = QAndroidJniObject::getStaticObjectField<jstring>("android/provider/AlarmClock",
    //                                                                                   "EXTRA_MESSAGE");
    //QAndroidJniObject messageObject = QAndroidJniObject::fromString(path);
    //intent.callObjectMethod("putExtra",
    //                        "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;",
    //                        EXTRA_MESSAGE.object<jstring>(),
    //                        messageObject.object<jstring>());

    ////QAndroidJniObject EXTRA_LENGTH = QAndroidJniObject::getStaticObjectField<jstring>("android/provider/AlarmClock",
    ////                                                                                  "EXTRA_LENGTH");
    ////intent.callObjectMethod("putExtra",
    ////                        "(Ljava/lang/String;I)Landroid/content/Intent;",
    ////                        EXTRA_LENGTH.object<jstring>(),
    ////                        jint(1 * 60));

    //QAndroidJniObject EXTRA_SKIP_UI = QAndroidJniObject::getStaticObjectField<jstring>("android/provider/AlarmClock",
    //                                                                                  "EXTRA_SKIP_UI");
    //intent.callObjectMethod("putExtra",
    //                        "(Ljava/lang/String;Z)Landroid/content/Intent;",
    //                        EXTRA_SKIP_UI.object<jstring>(),
    //                        jboolean(true));

    //auto intent = QAndroidIntent("ACTION_SEND");
    //shareIntent.putExtra("EXTRA_STREAM", "blah");

//    auto ACTION_SEND = QAndroidJniObject::getStaticObjectField<jstring>("android/content/Intent",
//                                                                                    "ACTION_SEND");
//    QAndroidJniObject intent("android/content/Intent",
//                             "(Ljava/lang/String;)V",
//                             ACTION_SEND.object());
//
//    QAndroidJniObject jfilePath = QAndroidJniObject::fromString(path);
//    QAndroidJniObject jfileType = QAndroidJniObject::fromString("image/png");
//
//    QAndroidJniObject fileUri = QAndroidJniObject("android.net.Uri");
//    auto uri = QAndroidJniObject::fromString(path);
//    fileUri.callObjectMethod("fromFile", "(II)Ljava/lang/String;", "file:///storage/emulated/0/Pictures/creativpainter.autosave.png");
//
//
//    intent.callObjectMethod("setDataAndType",
//                            "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;",
//                            //jfilePath.object<jstring>(),
//                            jfileType.object<jstring>());
//
//    auto EXTRA_TEXT = QAndroidJniObject::getStaticObjectField<jstring>("android/content/Intent",
//                                                                                       "EXTRA_TEXT");
//    intent.callObjectMethod("putExtra",
//                            "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;",
//                            EXTRA_TEXT.object(),
//                            QAndroidJniObject::fromString("blah").object<jstring>());
//
//                            //fileUri.object());
//
//    //QtAndroid::startActivity(intent, 0, &imageIOReceiver);

    QAndroidJniObject activity = QtAndroid::androidActivity();
    QAndroidJniObject packageManager = activity.callObjectMethod("getPackageManager",
                                                                 "()Landroid/content/pm/PackageManager;");
    QAndroidJniObject componentName = intent.callObjectMethod("resolveActivity",
                                                              "(Landroid/content/pm/PackageManager;)Landroid/content/ComponentName;",
                                                              packageManager.object());
    if (componentName.isValid())
        QtAndroid::startActivity(intent, 0);
    else
        qWarning("Unable to resolve activity :-(");

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
