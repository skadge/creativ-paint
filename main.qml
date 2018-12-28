import QtQuick 2.7
import QtQuick.Window 2.2
import QtMultimedia 5.5

import InteractiveCanvas 1.0
import ImageIO 1.0

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
                    //createPicture(preview);
                    drawingarea.bgImage = preview;
                    cameraCapture.visible=false;
                    camera.stop();
                }
            }
            function createPicture(picture) {
               var component = Qt.createComponent("GesturePicture.qml");
               var pic = component.createObject(drawing, {"source": picture, "width": Screen.width / 3, "z": 1});
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

        onIsopenChanged: {
            if (isopen) closeOtherDrawers(colorpicker);
        }
    }

    Drawer {
        id: tools

        onIsopenChanged: {
            if (isopen) closeOtherDrawers(tools);
        }


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
                        drawingarea.clear()
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

        onIsopenChanged: {
            if (isopen) closeOtherDrawers(penWidthChooser);
        }

        handle.right: penDrawerContainer.right
        handle.top: penDrawerContainer.bottom
        handlecolor: "#9c27b0"
        icon: drawingarea.mode == InteractiveCanvas.FILL ? "round-format_color_fill-24px.svg" : (drawingarea.mode == InteractiveCanvas.DRAW ? "round-create-24px.svg" : "eraser-solid.svg")

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
                            return children[i].sizefactor * Screen.width/12;
                    }
                    return 10;
                }
                function deselectAll() {
                    penlarge.selected = false;
                    penmedium.selected = false;
                    pensmall.selected = false;
                    penxsmall.selected = false;
                }

                function uniqueSelect(pen) {
                    deselectAll();
                    drawingarea.mode=InteractiveCanvas.DRAW;
                    penWidthChooser.close();
                    pen.selected = true;
                }


                Button {
                    id: pencil
                    color: colorpicker.paintbrushColor
                    icon: "round-create-24px.svg"
                    selected: drawingarea.mode == InteractiveCanvas.DRAW
                    onTapped: {
                        penWidthChooser.close();
                        drawingarea.mode=InteractiveCanvas.DRAW;
                    }

                }

                Button {
                    id: fillbucket
                    color: colorpicker.paintbrushColor
                    icon: "round-format_color_fill-24px.svg"
                    selected: drawingarea.mode == InteractiveCanvas.FILL
                    onTapped: {
                        penWidthChooser.close();
                        drawingarea.mode=InteractiveCanvas.FILL;
                    }

                }

                Button {
                    id: eraser
                    //color: colorpicker.paintbrushColor
                    icon: "eraser-solid.svg"
                    selected: drawingarea.mode == InteractiveCanvas.ERASE
                    onTapped: {
                        penWidthChooser.close();
                        drawingarea.mode=InteractiveCanvas.ERASE;
                    }

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

    function closeOtherDrawers(drawer) {
        if ( drawer !== penWidthChooser) penWidthChooser.close();
        if ( drawer !== tools) tools.close();
        if ( drawer !== colorpicker) colorpicker.close();
    }
    function closeAllDrawers() {
        closeOtherDrawers(undefined);
    }

    Button {
        icon: "round-share-24px"
        color: "#03a9f4"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        shadow: true

        z: 5

        onTapped: {
            closeAllDrawers();
            var path = drawingarea.save();
            console.log("Saving picture to " + path);
            imageio.shareImage(path);
        }


    }

    ImageIO {
        id: imageio
    }

    Rectangle {
        id: drawing
        anchors.fill: parent

        color: Qt.rgba(0,0,0,0)

        property var pictures: []
        property var selectedPicture

        property int highestZ: 1

        MultiPointTouchArea {
                id: touchArea
                anchors.fill: parent

                onPressed: {
                    closeAllDrawers()
                }

                touchPoints: [
                    TouchPoint {id:touch1},
                    TouchPoint {id:touch2},
                    TouchPoint {id:touch3},
                    TouchPoint {id:touch4},
                    TouchPoint {id:touch5},
                    TouchPoint {id:touch6}
                ]

        InteractiveCanvas {
            id: drawingarea
            anchors.fill: parent

            size: penWidthChooser.penWidth
            color: colorpicker.paintbrushColor
            //bgImage: "res/tutorial_bg.svg"
        }
            }


        ParticleFlame {
                color: colorpicker.paintbrushColor
                emitterX: touch1.x
                emitterY: touch1.y
                emitting: touch1.pressed
        }

        ParticleFlame {
                color: colorpicker.paintbrushColor
                emitterX: touch2.x
                emitterY: touch2.y
                emitting: touch2.pressed

        }
        ParticleFlame {
                color: colorpicker.paintbrushColor
                emitterX: touch3.x
                emitterY: touch3.y
                emitting: touch3.pressed
        }
        ParticleFlame {
                color: colorpicker.paintbrushColor
                emitterX: touch4.x
                emitterY: touch4.y
                emitting: touch4.pressed
        }

}
}
