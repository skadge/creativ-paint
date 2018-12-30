TEMPLATE = app

linux:!android {
    message("* Using settings for Linux.")
    QT += qml quick widgets multimedia
}

android {
    message("* Using settings for Android.")
    QT += qml quick widgets svg xml gui core androidextras multimedia
}

CONFIG += c++11

SOURCES += main.cpp \
    imageio.cpp \
    interactivecanvas.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =
#QML_IMPORT_PATH = /home/skadge/applis/Qt/5.11.2/gcc_64/qml

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    AndroidManifest.xml \
    templates/AndroidManifest.xml \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    android/src/org/guakamole/shareimage/ShareImage.java \
    round-done-24px.svg

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

HEADERS += \
    imageio.h \
    interactivecanvas.h
