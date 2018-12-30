import QtQuick 2.6
import QtGraphicalEffects 1.0
import QtQuick.Window 2.2

Image {
    id: picture

    fillMode: Image.PreserveAspectFit

    property bool controlVisible: true

    signal imagePlaced(var myself)

    width:50
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2

    Behavior on scale { PropertyAnimation{}}

    Button {
        icon: "round-open_with-24px.svg"
        width: parent.width * 0.5
        opacity: 0.5
        visible: controlVisible
        color: Qt.rgba(0,0,0,0) // transparent

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }


    PinchArea {
        id: pincharea
        anchors.fill: parent
        pinch.target: picture
        pinch.minimumRotation: -360
        pinch.maximumRotation: 360
        pinch.minimumScale: 0.1
        pinch.maximumScale: 10
        pinch.dragAxis: Pinch.XAndYAxis

        onPinchStarted: {
            picture.scale *= 1.1;
        }

        MouseArea {
            id: dragArea
            hoverEnabled: true
            anchors.fill: parent
            drag.target: picture
            scrollGestureEnabled: false  // 2-finger-flick gesture should pass through to the Flickable
            onPressed: {
                picture.scale *= 1.1;

            }
            onReleased: {
                picture.scale /= 1.1;
            }

            onWheel: {
                if (wheel.modifiers & Qt.ControlModifier) {
                    picture.rotation += wheel.angleDelta.y / 120 * 5;
                    if (Math.abs(picture.rotation) < 4)
                        picture.rotation = 0;
                } else {
                    picture.rotation += wheel.angleDelta.x / 120;
                    if (Math.abs(picture.rotation) < 0.6)
                        picture.rotation = 0;
                    var scaleBefore = picture.scale;
                    picture.scale += picture.scale * wheel.angleDelta.y / 120 / 10;
                }
            }
        }

        Button {
            icon: "round-done-24px.svg"
            color: "green"
            selected: true

            visible: controlVisible

            anchors.right: parent.right
            anchors.rightMargin: width/2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: width/2

            onTapped:{
                dragArea.enabled = false;
                controlVisible = false;
                imagePlaced(picture)
            }
        }

    }
}
