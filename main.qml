import QtQuick 2.7
import QtQuick.Window 2.2
import QtMultimedia 5.5

Window {
    visible: true
    visibility: "FullScreen"
    width:1200
    height:900
    title: qsTr("Touch Paint")

    Rectangle {
        id:background
        color: "white"
        anchors.fill: parent
    }

    Item {
        id: cameraCapture
        anchors.fill: parent
        visible: false

        z: 20

        Camera {
            id: camera

            cameraState: Camera.LoadedState

            imageCapture {
                onImageCaptured: {
                    createPicture(preview);
                    cameraCapture.visible=false;
                    camera.stop();
                }
            }
            function createPicture(picture) {
               var component = Qt.createComponent("GesturePicture.qml");
               var pic = component.createObject(drawing, {"source": picture, "width": Screen.width / 3, "z": ++drawing.highestZ});
                drawing.pictures.push(pic);
            }
}

        VideoOutput {
            id: videoOutput
            source: camera
            focus : visible // to receive focus and capture key events when visible
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent;
                onClicked: camera.imageCapture.capture();
            }
        }

    }

    ColorPicker {
        id: colorpicker
        z:5
    }

    Drawer {
        id: tools

        anchors.left: parent.left
        topDrawer: false
        icon: "round-more_horiz-24px.svg"

        handle.bottom: toolsDrawerContainer.top
        handle.left: toolsDrawerContainer.left
        handlecolor: "#ffc107"

        z: 5

        Rectangle {
            id: toolsDrawerContainer
            color: "#ffecb3"

            height: childrenRect.height
            width: Screen.width

            Grid {
                id: toolsGrid

                Button {
                    icon: "round-photo_camera-24px.svg"
                    onTapped: {
                        tools.close();
                        camera.start();
                        cameraCapture.visible=true;
                    }
                }

                Button {
                    icon: "round-delete_forever-24px.svg"

                    onTapped: {
                        tools.close();
                        canvas.clear()
                        for(var i = 0; i < drawing.pictures.length; i++) {
                            var pic = drawing.pictures.pop();
                            pic.destroy();
                        }
                    }
                }
            }
        }
    }

    Drawer {
        id: penWidthChooser

        anchors.right: parent.right
        z: 5

        handle.right: penDrawerContainer.right
        handle.top: penDrawerContainer.bottom
        handlecolor: "#9c27b0"
        icon: "round-create-24px.svg"

        property alias penWidth: sizeGrid.penWidth

        Rectangle {
            id: penDrawerContainer
            color: "#e1bee7"

            height: childrenRect.height
            width: Screen.width

            Grid {
                anchors.right: parent.right
                id: sizeGrid
                columns: 8
                layoutDirection: Qt.RightToLeft

                property real penWidth: {
                    for (var i = 0; i < children.length; i++) {
                        if(children[i].selected)
                            return children[i].sizefactor * 75;
                    }
                    return 10;
                }
                function uniqueSelect(pen) {
                    penWidthChooser.close();
                    penlarge.selected = false;
                    penmedium.selected = false;
                    pensmall.selected = false;
                    penxsmall.selected = false;
                    pen.selected = true;
                }


                Button {
                    id: penlarge
                    sizefactor: 1.0
                    color: colorpicker.paintbrushColor
                    onTapped: sizeGrid.uniqueSelect(penlarge)

                }
                Button {
                    id: penmedium
                    sizefactor: 0.7
                    color: colorpicker.paintbrushColor
                    onTapped: sizeGrid.uniqueSelect(penmedium)
                }
                Button {
                    id: pensmall
                    sizefactor: 0.5
                    color: colorpicker.paintbrushColor
                    selected: true
                    onTapped: sizeGrid.uniqueSelect(pensmall)
                }
                Button {
                    id: penxsmall
                    sizefactor: 0.2
                    color: colorpicker.paintbrushColor
                    onTapped: sizeGrid.uniqueSelect(penxsmall)
                }
            }
        }
    }

    Rectangle {
        id: drawing
        anchors.fill: parent

        color: Qt.rgba(0,0,0,0)

        property var pictures: []
        property var selectedPicture

        property int highestZ: 1
        property alias drawingColor: colorpicker.color

        property var strokes: []

        MultiPointTouchArea {
                id: touchArea
                anchors.fill: parent

                touchPoints: [
                    TouchJoint {id:touch1;name:"touch1"},
                    TouchJoint {id:touch2;name:"touch2"},
                    TouchJoint {id:touch3;name:"touch3"},
                    TouchJoint {id:touch4;name:"touch4"},
                    TouchJoint {id:touch5;name:"touch5"},
                    TouchJoint {id:touch6;name:"touch6"}
                ]
            }

        DrawingArea {
            id: drawingarea
            height: parent.height
            width: parent.width
            anchors.left: parent.left
            anchors.top: parent.top

            lineWidth: penWidthChooser.penWidth
            fgColor: colorpicker.paintbrushColor
            //bgImage: "res/tutorial_bg.svg"

            touchs: touchArea
        }


        ParticleFlame {
                color: touch1.color
                emitterX: touch1.x
                emitterY: touch1.y
                emitting: touch1.pressed
        }

        ParticleFlame {
                color: touch2.color
                emitterX: touch2.x
                emitterY: touch2.y
                emitting: touch2.pressed

        }
        ParticleFlame {
                color: touch3.color
                emitterX: touch3.x
                emitterY: touch3.y
                emitting: touch3.pressed
        }

}
}