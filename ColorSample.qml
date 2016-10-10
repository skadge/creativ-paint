import QtQuick 2.0

Button {

    id: colorsampler

    Rectangle {
        id: dot
        width: parent.width/2
        visible: parent.selected?true:false
        height: width
        radius: width/2
        color: Qt.darker(parent.color)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

}
