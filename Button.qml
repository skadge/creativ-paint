import QtQuick 2.0
import QtQuick.Window 2.2

Rectangle {

    id: myself

    width: Screen.width/12
    height: width

    property bool selected: false
    property alias icon: icon.source

    z: selected ? 11 : 10
    signal tapped(var myself)

    border.width: selected ? 10 : 0
    border.color: Qt.darker(color)

    color: "grey"


    MouseArea {
        anchors.fill: parent
        onClicked: tapped(myself)
    }
    Image {
        id: icon
        width: parent.width * 0.75
        height: width
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

}
