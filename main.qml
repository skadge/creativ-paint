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

        onColorUpdated: {
            canvas.z=++drawing.highestZ;
        }
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
        icon: "sizes.svg"

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
                    color: colorpicker.color
                    onTapped: sizeGrid.uniqueSelect(penlarge)

                }
                Button {
                    id: penmedium
                    sizefactor: 0.7
                    color: colorpicker.color
                    onTapped: sizeGrid.uniqueSelect(penmedium)
                }
                Button {
                    id: pensmall
                    sizefactor: 0.5
                    color: colorpicker.color
                    selected: true
                    onTapped: sizeGrid.uniqueSelect(pensmall)
                }
                Button {
                    id: penxsmall
                    sizefactor: 0.2
                    color: colorpicker.color
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
        property alias lineWidth: penWidthChooser.penWidth

        MultiPointTouchArea {
                id:touchs
                anchors.fill: parent
                minimumTouchPoints: 1
                maximumTouchPoints: 5
                touchPoints: [
                        TouchPoint {
                            id: touch1
                            property var currentStroke: []
                            onYChanged: drawing.addPoint(x, y, currentStroke)
                            onPressedChanged: {
                                if (!pressed) {
                                    drawing.finishStroke(currentStroke);
                                    currentStroke = [];
                                }
                            }

                            property alias color: drawing.drawingColor
                        },
                        TouchPoint { id: touch2
                                    property var currentStroke: []
                                    onYChanged: drawing.addPoint(x, y, currentStroke)
                                    onPressedChanged: {
                                        if (!pressed) {
                                            drawing.finishStroke(currentStroke);
                                            currentStroke = [];
                                        }
                                    }

                                    property alias color: drawing.drawingColor

                        },
                        TouchPoint { id: touch11
                                    property var currentStroke: []
                                    onYChanged: drawing.addPoint(x, y, currentStroke)
                                    onPressedChanged: {
                                        if (!pressed) {
                                            drawing.finishStroke(currentStroke);
                                            currentStroke = [];
                                        }
                                    }

                                    property alias color: drawing.drawingColor

                        }
                ]
                onGestureStarted: {
                    canvas.z= ++drawing.highestZ;
                }

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
                color: touch11.color
                emitterX: touch11.x
                emitterY: touch11.y
                emitting: touch11.pressed
        }

        Canvas {
                id: canvas
                antialiasing: true
                opacity: 1
                property real alpha: 0.8

                anchors.fill: parent

                function clear() {

                    var ctx = canvas.getContext('2d');
                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                    requestPaint();

                }

                onPaint: {
                        //if (drawing.currentStroke.length === 0 && drawing.strokes.length === 0) return;
                        //if (drawing.currentStroke.length === 0) return;

                        var strokeIdx = 0;
                        var i = 0;
                        var ctx = canvas.getContext('2d');
                        //ctx.clearRect(0, 0, canvas.width, canvas.height);

                        ctx.globalAlpha = canvas.alpha;


                        ctx.lineJoin = "round"
                        ctx.lineCap="round";

                        //var allStrokes = drawing.strokes;
                        var allStrokes = [];
                        for (var i = 0; i < touchs.touchPoints.length; i++) {

                            if(touchs.touchPoints[i].currentStroke.length !== 0) {
                                allStrokes.push({color: drawing.drawingColor.toString(),
                                                 points: touchs.touchPoints[i].currentStroke,
                                                 width: drawing.lineWidth
                                                });
                            }
                        }

                        for (strokeIdx = 0; strokeIdx < allStrokes.length; strokeIdx++) {
                                var points = allStrokes[strokeIdx].points;
                                var width = allStrokes[strokeIdx].width;

                                ctx.lineWidth = width;

                                ctx.beginPath();
                                ctx.strokeStyle = allStrokes[strokeIdx].color;

                                var p1 = points[0];
                                var p2 = points[1];

                                ctx.moveTo(p1.x, p1.y);

                                for (i = 1; i < points.length; i++)
                                {
                                        // we pick the point between pi+1 & pi+2 as the
                                        // end point and p1 as our control point
                                        var midPoint = midPointBtw(p1, p2);
                                        ctx.quadraticCurveTo(p1.x, p1.y, midPoint.x, midPoint.y);
                                        p1 = points[i];
                                        p2 = points[i+1];

                                }
                                ctx.lineTo(p1.x, p1.y);
                                ctx.stroke();
                       }
                }

                function midPointBtw(p1, p2) {
                  return {
                    x: p1.x + (p2.x - p1.x) / 2,
                    y: p1.y + (p2.y - p1.y) / 2
                  };
                }

        }

        function addPoint(x, y, stroke) {
            stroke.push(Qt.point(x,y));
            canvas.requestPaint();
        }

        function finishStroke(stroke) {
            if (stroke.length == 0) return;

            strokes.push({color: drawing.drawingColor.toString(),
                          points: stroke,
                          width: drawing.lineWidth
                         });
            stroke = [];
        }
    }
}
