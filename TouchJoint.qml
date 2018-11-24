import QtQuick 2.0


TouchPoint {

    id: touch

    property string name: "touch"
    property bool movingItem: false
    property bool drawing: false

    // when used to draw on the background:
    property var currentStroke: []
    property color color: "black"

    onXChanged: {

        if(movingItem) {
            joint.target = Qt.point(x, y);
        }

        // (only add stroke point in one dimension (Y) to avoid double drawing)
    }

    onYChanged: {
        if(movingItem) {
            joint.target = Qt.point(x, y);
        }

        if (drawing) {
            currentStroke.push(Qt.point(x,y));
            drawingarea.update();
        }
    }
    onPressedChanged: {

        if (pressed) {

                currentStroke = [];
                color = drawingarea.fgColor;
                drawing = true;

        }
        else { // released
            if(drawing) {
                drawing = false;
                drawingarea.finishStroke(currentStroke);
                currentStroke = [];
            }
        }
    }

}

