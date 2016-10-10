import QtQuick 2.6
import QtGraphicalEffects 1.0

Image {
        id: picture


        z:1
        fillMode: Image.PreserveAspectFit

        Behavior on scale { PropertyAnimation{}}

//        Rectangle {
            Image {
            source: "hand.svg"
            width:100
            height: width
            //radius: width/2
            anchors.left: parent.left
            anchors.leftMargin: -width/2
            anchors.top: parent.top
            anchors.topMargin: -width/2
            //color:"grey"
            //border.color:Qt.darker(color)
            //border.width:20

            MouseArea {
                anchors.fill: parent
                onClicked: picture.z = ++picture.parent.highestZ
            }
        }

        PinchArea {
                anchors.fill: parent
                pinch.target: picture
                pinch.minimumRotation: -360
                pinch.maximumRotation: 360
                pinch.minimumScale: 0.1
                pinch.maximumScale: 10
                pinch.dragAxis: Pinch.XAndYAxis

                enabled: picture.z >= picture.parent.highestZ

                onPinchStarted: {
                        picture.z = ++picture.parent.highestZ + 1;
                        picture.scale *= 1.1;
                }

                MouseArea {
                        id: dragArea
                        enabled: picture.z >= picture.parent.highestZ
                        hoverEnabled: true
                        anchors.fill: parent
                        drag.target: picture
                        scrollGestureEnabled: false  // 2-finger-flick gesture should pass through to the Flickable
                        onPressed: {
                                picture.z = ++picture.parent.highestZ + 1;
                                picture.scale *= 1.1;

                        }
                        onReleased: {
                            picture.scale /= 1.1;
                        }

                        //onEntered: parent.setFrameColor();
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
        }
}
