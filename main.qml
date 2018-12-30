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
                    camera.stop();
                    cameraCapture.visible=false;
                    picturePlacer.source = preview;
                    picturePlacer.enabled = true;
                    drawing.state = "img_placement";
                }
            }
        }

        VideoOutput {
            id: videoOutput
            source: camera
            focus : visible // to receive focus and capture key events when visible
            anchors.fill: parent

            Button {
                color: "red"
                width: Screen.width/8
                selected: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: width/3

                onTapped: {
                    camera.imageCapture.capture();
                }
            }
        }

    }

    ColorPicker {
        id: colorpicker
        visible: drawing.state == "drawing"
        z: 5

        onIsopenChanged: {
            if (isopen) closeOtherDrawers(colorpicker);
        }

        onColorUpdated: {
            if(drawingarea.mode == InteractiveCanvas.FILL) {
                drawingarea.mode = InteractiveCanvas.DRAW;
            }
        }
    }
    Drawer {
        id: toolsDrawer
        visible: drawing.state == "drawing"

        anchors.right: parent.right
        z: 5

        onIsopenChanged: {
            if (isopen) closeOtherDrawers(toolsDrawer);
        }

        handle.left: penDrawerContainer.left
        handle.top: penDrawerContainer.bottom
        handlecolor: colorpicker.paintbrushColor
        icon: drawingarea.mode == InteractiveCanvas.FILL ? "round-format_color_fill-24px.svg" : (drawingarea.mode == InteractiveCanvas.DRAW ? "round-create-24px.svg" : "eraser-solid.svg")

        property alias penWidth: sizeGrid.penWidth

        Rectangle {
            id: penDrawerContainer
            color: "#e1bee7"

            height: childrenRect.height
            width: Screen.width

            Grid {
                anchors.left: parent.left
                id: toolGrid
                columns: 8
                layoutDirection: Qt.LeftToRight

                Button {
                    id: pencil
                    color: colorpicker.paintbrushColor
                    icon: "round-create-24px.svg"
                    selected: drawingarea.mode == InteractiveCanvas.DRAW
                    onTapped: {
                        toolsDrawer.close();
                        drawingarea.mode=InteractiveCanvas.DRAW;
                    }

                }

                Button {
                    id: fillbucket
                    color: colorpicker.paintbrushColor
                    icon: "round-format_color_fill-24px.svg"
                    selected: drawingarea.mode == InteractiveCanvas.FILL
                    onTapped: {
                        toolsDrawer.close();
                        drawingarea.mode=InteractiveCanvas.FILL;
                    }

                }

                //Button {
                //    id: eraser
                //    icon: "eraser-solid.svg"
                //    selected: drawingarea.mode == InteractiveCanvas.ERASE
                //    onTapped: {
                //        toolsDrawer.close();
                //        drawingarea.mode=InteractiveCanvas.ERASE;
                //    }

                //}
            }
            Grid {
                anchors.right: parent.right
                id: sizeGrid
                columns: 8
                layoutDirection: Qt.LeftToRight

                property real sizefactor: 0.5
                property real penWidth: sizefactor * Screen.width/12

                function deselectAll() {
                    penlarge.selected = false;
                    penmedium.selected = false;
                    pensmall.selected = false;
                    penxsmall.selected = false;
                }

                function uniqueSelect(pen) {
                    deselectAll();
                    drawingarea.mode=InteractiveCanvas.DRAW;
                    toolsDrawer.close();
                    sizefactor = pen.sizefactor;
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

    Drawer {
        id: extrasDrawer

        onIsopenChanged: {
            if (isopen) closeOtherDrawers(extrasDrawer);
        }

        visible: drawing.state == "drawing"


        anchors.left: parent.left
        topDrawer: false
        icon: "round-more_horiz-24px.svg"

        handle.bottom: toolsDrawerContainer.top
        handle.right: toolsDrawerContainer.right
        handlecolor: "#ffc107"

        z: 5

        Rectangle {
            id: toolsDrawerContainer
            color: "#ffecb3"

            height: childrenRect.height
            width: Screen.width

            Grid {
                id: toolsGrid
                layoutDirection: Qt.RightToLeft
                anchors.right: parent.right

                Button {
                    icon: "round-share-24px"

                    visible: Qt.platform.os == "android"

                    onTapped: {
                        extrasDrawer.close();
                        var path = drawingarea.save();
                        imageio.shareImage(path);
                    }


                }


                Button {
                    icon: "round-delete_forever-24px.svg"

                    onTapped: {
                        extrasDrawer.close();
                        drawingarea.clear()
                    }
                }
            }
        }
    }


    Button {
        icon: "round-photo_camera-24px.svg"
        color: "#03a9f4"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        shadow: true

        visible: drawing.state == "drawing"

        z: 5
        onTapped: {
            closeAllDrawers();
            camera.start();
            cameraCapture.visible=true;
        }
    }

    Button {
        icon: "round-done-24px.svg"
        color: "green"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        shadow: true

        visible: drawing.state == "img_placement"

        z: 5
        onTapped:{
            picturePlacer.enabled = false;
            picturePlacer.imagePlaced(picturePlacer);
            drawing.state = "drawing"
        }
    }

    function closeOtherDrawers(drawer) {
        if ( drawer !== toolsDrawer) toolsDrawer.close();
        if ( drawer !== extrasDrawer) extrasDrawer.close();
        if ( drawer !== colorpicker) colorpicker.close();
    }

    function closeAllDrawers() {
        closeOtherDrawers(undefined);
    }

    ImageIO {
        id: imageio
    }

    GesturePicture {
        id: picturePlacer
        width: Screen.width/2
        visible: drawing.state == "img_placement"
        z: 1
        onImagePlaced: {
            drawingarea.insertImage(picturePlacer)
        }
    }

    Rectangle {
        id: drawing
        anchors.fill: parent

        states: [
            State {
                name:"drawing"
            },
            State {
                name: "img_placement"

            }
        ]
        state: "drawing"


        color: Qt.rgba(0,0,0,0)

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

                size: toolsDrawer.penWidth
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

