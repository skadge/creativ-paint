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

                if (fillbucket) {
                    var x =touchs.touchPoints[i].startX;
                    var y =touchs.touchPoints[i].startY;
                    floodfill(Math.round(x) * 2, Math.round(y) * 2);

                }
                else {
                    if(touchs.touchPoints[i].currentStroke.length !== 0) {
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
            drawingarea.fillbucket = false; // automatically return to 'pencil' mode

            var ctx = canvas.getContext('2d');
            ctx.drawImage(lastCanvasData,0,0);

            //ctx.fillRect(x/2-10, y/2-10,20,20);

            requestPaint();

        }


        function sameColor(canvasData, idx, color) {
            return    canvasData.data[idx] === color[0]
                    && canvasData.data[idx + 1] === color[1]
                    && canvasData.data[idx + 2] === color[2]
                    && canvasData.data[idx + 3] === color[3];
        }

        function setColor(canvasData, idx, color) {

            canvasData.data[idx] = color[0];
            canvasData.data[idx + 1] = color[1];
            canvasData.data[idx + 2] = color[2];
            canvasData.data[idx + 3] = color[3];
        }



        /* Algo based on https://en.wikipedia.org/wiki/Flood_fill
        */
        function floodfill_inner(canvasData, sx, sy, target_color, replace_color) {

            if (sameColor(canvasData, (sy * canvasData.width + sx) * 4, replace_color)) return;

            var pixel_stack = [[sx, sy]];

            while(pixel_stack.length)
            {
                var new_pos, x, y, pixel_pos, reach_left, reach_right;
                new_pos = pixel_stack.pop();
                x = new_pos[0]; y = new_pos[1];

                pixel_pos = (y * canvasData.width + x) * 4;

                while(y-- >= 0 && sameColor(canvasData, pixel_pos, target_color)) {
                    pixel_pos -= canvasData.width * 4;
                }

                pixel_pos += canvasData.width * 4;
                ++y;

                reach_left = false;
                reach_right = false;

                while(y++ < canvasData.height-1 && sameColor(canvasData, pixel_pos, target_color)) {

                    setColor(canvasData, pixel_pos, replace_color);

                    if(x > 0) {

                        if(sameColor(canvasData, pixel_pos - 4, target_color)) {

                            if(!reach_left) {
                                pixel_stack.push([x - 1, y]);
                                reach_left = true;
                            }
                        }
                        else if(reach_left) {
                            reach_left = false;
                        }
                    }

                    if(x < canvasData.width-1) {

                        if(sameColor(canvasData, pixel_pos + 4, target_color)) {
                            if(!reach_right) {
                                pixel_stack.push([x + 1, y]);
                                reach_right = true;
                            }
                        }
                        else if(reach_right) {
                            reach_right = false;
                        }
                    }

                    pixel_pos += canvasData.width * 4;
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
