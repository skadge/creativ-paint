import QtQuick 2.0

Button {

    id: sizechooser

    property real penWidth: 25

    Rectangle {
        id: dot
        width: parent.penWidth
        height: width
        radius: width/2
        color: Qt.darker(parent.color)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

}
