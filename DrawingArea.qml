import QtQuick 2.2
import Qt.labs.platform 1.0
import org.skadge.imageio 1.0

Item {

    id: drawingarea

    property double pixelscale: 1.0 // how many meters does 1 pixel represent?

    property bool fillbucket: false // if true, a click fills the underlying pixels

    property string bgImage
    property int lineWidth: 50

    property color fgColor

    property bool drawEnabled: true

    property var touchs


    Canvas {
        id: canvas
        antialiasing: false // disable antialiasing to improve filling on edges
        opacity: 1
        property real alpha: 1

        property var lastCanvasData
        property var bgCanvasData

        anchors.fill: parent

        function storeCurrentDrawing() {
            var ctx = canvas.getContext('2d');
            lastCanvasData = ctx.getImageData(0,0,width, height);
        }

        onPaint: {

            var strokeIdx = 0;
            var i = 0;
            var ctx = canvas.getContext('2d');

            //ctx.reset();

            ctx.globalAlpha = canvas.alpha;


            // background image not yet loaded
            // if(!bgCanvasData) return;

            if (bgCanvasData) ctx.drawImage(bgCanvasData,0,0);
            if (lastCanvasData) ctx.drawImage(lastCanvasData,0,0);

            ctx.lineJoin = "round"
            ctx.lineCap="round";

            var currentStrokes = [];
            for (var i = 0; i < touchs.touchPoints.length; i++) {

                if(touchs.touchPoints[i].currentStroke.length !== 0) {
                    if (fillbucket) {
                        var p =touchs.touchPoints[i].currentStroke.pop();
                        floodfill(Math.round(p.x) * 2, Math.round(p.y) * 2);

                    }
                    else {

                        currentStrokes.push({color: touchs.touchPoints[i].color.toString(),
                                points: touchs.touchPoints[i].currentStroke,
                                width: drawingarea.lineWidth
                            });
                    }
                }
            }

            for (strokeIdx = 0; strokeIdx < currentStrokes.length; strokeIdx++) {
                var points = currentStrokes[strokeIdx].points;
                var width = currentStrokes[strokeIdx].width;

                ctx.lineWidth = width;

                ctx.beginPath();

                var prevCompositeMode = ctx.globalCompositeOperation;

                // are we in 'eraser' mode (ie, 'transparent' color)?
                // if yes, change the composite mode to erase the canvas
                // instead of painting over
                if(currentStrokes[strokeIdx].color === "#00000000") {
                    ctx.globalCompositeOperation = "destination-out";
                    ctx.strokeStyle = "black";
                }
                else {
                    ctx.strokeStyle = currentStrokes[strokeIdx].color;
                }

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

                // if in eraser mode,
                // 1- restore the composite mode ('paint over')
                // 2- redraw the background
                // 3- overlay the drawings
                if(currentStrokes[strokeIdx].color === "#00000000") {
                    ctx.globalCompositeOperation = prevCompositeMode;
                    lastCanvasData = ctx.getImageData(0,0,canvas.width, canvas.height);
                    gc(); // explicitely call the garbage collector, otherwise, memory leaks

                    //ctx.drawImage(bgCanvasData,0,0);
                    ctx.drawImage(lastCanvasData,0,0);
                }
            }

        }

        function midPointBtw(p1, p2) {
            return {
                x: p1.x + (p2.x - p1.x) / 2,
                y: p1.y + (p2.y - p1.y) / 2
            };
        }

        onImageLoaded: {
            lastCanvasData = null;
            bgCanvasData = null;
            // storing the background image -- needed to repaint background when using the rubber
            var ctx = canvas.getContext('2d');
            bgCanvasData = ctx.createImageData(drawingarea.bgImage);
            requestPaint();
        }


        function floodfill(x,y) {

            drawingarea.fillbucket = false; // automatically return to 'pencil' mode

            var r = Math.round(drawingarea.fgColor.r * 255);
            var g = Math.round(drawingarea.fgColor.g * 255);
            var b = Math.round(drawingarea.fgColor.b * 255);
            var a = Math.round(drawingarea.fgColor.a * 255);
            var color = [r,g,b,a];

            if (lastCanvasData === undefined) storeCurrentDrawing();

            var tr = lastCanvasData.data[(y * lastCanvasData.width + x) * 4];
            var tg = lastCanvasData.data[(y * lastCanvasData.width + x) * 4 + 1];
            var tb = lastCanvasData.data[(y * lastCanvasData.width + x) * 4 + 2];
            var ta = lastCanvasData.data[(y * lastCanvasData.width + x) * 4 + 3];
            var target_color = [tr,tg,tb,ta];

            floodfill_inner(lastCanvasData, x, y, target_color, color);

            var ctx = canvas.getContext('2d');
            ctx.drawImage(lastCanvasData,0,0);

            //ctx.fillRect(x/2-10, y/2-10,20,20);

            requestPaint();

        }


        function sameColor(canvasData, x, y, color) {
            var idx = (y * canvasData.width + x) * 4;
            return    canvasData.data[idx] === color[0]
                   && canvasData.data[idx + 1] === color[1]
                   && canvasData.data[idx + 2] === color[2]
                   && canvasData.data[idx + 3] === color[3];
        }

        function setColor(canvasData, x, y, color) {

             canvasData.data[(y * canvasData.width + x) * 4] = color[0];
             canvasData.data[(y * canvasData.width + x) * 4 + 1] = color[1];
             canvasData.data[(y * canvasData.width + x) * 4 + 2] = color[2];
             canvasData.data[(y * canvasData.width + x) * 4 + 3] = color[3];
        }



        /* Algo based on https://en.wikipedia.org/wiki/Flood_fill
        */
        function floodfill_inner(canvasData, x, y, target_color, replace_color) {
            if (x < 0 || y < 0 || x >= lastCanvasData.width || y >= lastCanvasData.height) return;
            if (sameColor(canvasData, x, y, replace_color)) return;
            if (!sameColor(canvasData, x, y, target_color)) return;

            var Q = [];

            setColor(canvasData, x, y, replace_color);

            Q.push([x,y]);

            while(Q.length) {
                var p = Q.pop();
                x = p[0]; y = p[1];

                if ( x < lastCanvasData.width - 1 && sameColor(canvasData, x+1, y, target_color)) {
                    setColor(canvasData, x+1, y, replace_color);
                    Q.push([x+1, y]);
                }
                if (x > 0 && sameColor(canvasData, x-1, y, target_color)) {
                    setColor(canvasData, x-1, y, replace_color);
                    Q.push([x-1, y]);
                }
                if (y < lastCanvasData.height - 1 && sameColor(canvasData, x, y+1, target_color)) {
                    setColor(canvasData, x, y+1, replace_color);
                    Q.push([x, y+1]);
                }
                if (y > 0 && sameColor(canvasData, x, y-1, target_color)) {
                    setColor(canvasData, x, y-1, replace_color);
                    Q.push([x, y-1]);
                }

            }
        }

    }

    function clearDrawing() {
        canvas.lastCanvasData = null;
        var ctx = canvas.getContext('2d');
        ctx.drawImage(canvas.bgCanvasData,0,0);
        canvas.requestPaint();
        drawingPublisher.publish();
    }

    function update() {
        canvas.requestPaint();
    }

    onBgImageChanged: {
        if(canvas.isImageLoaded(drawingarea.bgImage)) {
            canvas.lastCanvasData = null;
            canvas.bgCanvasData = null;
            // storing the background image -- needed to repaint background when using the rubber
            var ctx = canvas.getContext('2d');
            canvas.bgCanvasData = ctx.createImageData(drawingarea.bgImage);
            canvas.requestPaint();
        }
        else {
            canvas.loadImage(drawingarea.bgImage);
        }
    }

    function finishStroke(stroke) {
        canvas.storeCurrentDrawing();
        stroke = [];
    }

    function save() {
        var path = StandardPaths.writableLocation(StandardPaths.PicturesLocation) + "/creativpainter.autosave.png";
        var shortpath = path.slice(7); // remove 'file://'
        console.info("Saving to " + shortpath);
        canvas.save(shortpath);
        imageio.shareImage(path);
    }

    ImageIO {
        id: imageio
    }
}
