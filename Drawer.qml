import QtQuick 2.0

Rectangle {

    id: drawer
    width: childrenRect.width
    height: childrenRect.height

    property alias handle: toggleButton.anchors
    property alias icon: toggleButton.icon
    property alias handlecolor: toggleButton.color

    property bool isopen: false
    property bool topDrawer: true
    x: 0
    y: topDrawer ? -height + toggleButton.height : parent.height

    color: Qt.rgba(0,0,0,0)

    Behavior on y {PropertyAnimation {}}

    Button {
        id: toggleButton
        z:100

        shadow: true
        color: "#009688"

        border.width: 10
        border.color: Qt.rgba(0,0,0,0)


        onTapped: {
            if (!isopen) {
                parent.open();
             }
            else {
                parent.close();
            }
        }

    }

    function open() {
                z=10;
                y = topDrawer ? 0 : parent.height - height + toggleButton.height
                isopen=true;
    }

    function close() {
                z=5;
                y = topDrawer ? -height + toggleButton.height : parent.height
                isopen=false;

    }

}
