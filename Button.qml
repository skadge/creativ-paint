import QtQuick 2.0
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

Item {

    id: myself
    property alias icon: icon.source
    property color color: "grey"
    property alias border: button.border

    property bool shadow: false
    property bool selected: false
    property double sizefactor : 1.0

    signal tapped(var myself)

    width: Screen.width/12
    height: width

    Rectangle {

        id: button

        width: parent.width * 0.8 * sizefactor
        height: width
        anchors.centerIn: parent
        radius: width/2


        z: selected ? 11 : 10

        border.width: selected ? 10 : 0
        border.color: selected ? Qt.darker(color) : 'white'

        color: parent.color == "#00000000" ? "grey" : parent.color


        Image {
            id: icon
            width: parent.width * 0.75
            height: width
            sourceSize.height: height // workaround for Qt not rendering the SVG at the correct resolution
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: tapped(myself)
    }

    DropShadow {
        cached: true
        anchors.fill: button
        radius: 20.0
        spread: 0.
        samples: 21
        color: shadow ? "#80000000":'transparent'
        source: button
    }

}
