import QtQuick 2.0

Rectangle {

    id: drawer
    width: childrenRect.width
    height: childrenRect.height

    property alias handle: toggleButton.anchors
    property alias icon: icon.source

    property bool topDrawer: true
    x: 0
    y: topDrawer ? -height + toggleButton.height : parent.height

    color: Qt.rgba(0,0,0,0)

    Behavior on y {PropertyAnimation {}}

    Button {
        id: toggleButton
        z:100

        color: Qt.rgba(0.5,0.5,0.5,0.5)

        border.width: 0

        property bool open: false

        onTapped: {
            if (!open) {
                parent.y = parent.topDrawer ? 0 : parent.parent.height - parent.height + toggleButton.height
                open=true;
                arrow.rotation= parent.topDrawer ? 180 : 0;
            }
            else {
                parent.y = parent.topDrawer ? -parent.height + toggleButton.height : parent.parent.height
                open=false;
                arrow.rotation= parent.topDrawer ? 0 : 180;
            }
        }

        Image {
            id: icon
            width: parent.width * 175/200
            height: parent.width * 80/200
            anchors.top: parent.top
            anchors.topMargin: topDrawer ? parent.width/10 : parent.height - height - parent.width/10
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Image {
            id: arrow
            width: parent.width * 145/200
            height: parent.width * 55/200
            anchors.bottom: parent.bottom
            anchors.bottomMargin: topDrawer? parent.width/10 : parent.height - height - parent.width/10
            rotation: topDrawer ? 0 : 180
            anchors.horizontalCenter: parent.horizontalCenter
            source: "flat_arrow.svg"
            Behavior on rotation {PropertyAnimation {} }
        }

    }

}
