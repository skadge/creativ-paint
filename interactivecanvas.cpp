#include <stack>

#include <QDebug>
#include <QPainter>
#include <QBrush>
#include <QDir>
#include <QStandardPaths>

#include "interactivecanvas.h"

typedef std::pair<int,int> point;

InteractiveCanvas::InteractiveCanvas(QQuickItem *parent) :
    QQuickPaintedItem(parent),
    _mode(DRAW)
{
    setAcceptedMouseButtons(Qt::AllButtons);
    setAcceptTouchEvents(true);
    //setAcceptHoverEvents(true);
}

void InteractiveCanvas::mousePressEvent(QMouseEvent *event) {
    //qDebug()<<"mousePressEvent(QMouseEvent *event)       "<<event;
}

void InteractiveCanvas::mouseMoveEvent(QMouseEvent *event) {
    //qDebug()<<"mouseMoveEvent(QMouseEvent *event)        "<<event;
}

void InteractiveCanvas::mouseReleaseEvent(QMouseEvent *event) {
    //qDebug()<<"mouseReleaseEvent(QMouseEvent *event)     "<<event;
}

//void InteractiveCanvas::mouseDoubleClickEvent(QMouseEvent *event)  {qDebug()<<"mouseDoubleClickEvent(QMouseEvent *event) "<<event;}
//void InteractiveCanvas::wheelEvent(QWheelEvent *event)             {qDebug()<<"wheelEvent(QWheelEvent *event)            "<<event;}

void InteractiveCanvas::touchEvent(QTouchEvent *event) {
    //qDebug()<<"touchEvent(QTouchEvent *event)            "<<event;

    //qDebug() << event->touchPoints().size() << " touchs";

    for(const auto& p : event->touchPoints()) {
        if(_mode == FILL) {
            _zones_to_fill.push_back(p.pos());
            update();
        }
        else if(_mode == DRAW) {
            if (p.state() & Qt::TouchPointPressed) {
                _strokes[p.id()].clear();
            }
            else if (p.state() & Qt::TouchPointReleased) {
                _strokes[p.id()].clear();
            }
            else if (p.state() & Qt::TouchPointMoved){
                _strokes[p.id()].push_back(p.pos());
                update();
            }
        }
        else {
            qDebug() << "Mode " << _mode << " not yet implemented";
        }

    }
}

//void InteractiveCanvas::hoverEnterEvent(QHoverEvent *event)        {qDebug()<<"hoverEnterEvent(QHoverEvent *event)       "<<event;}
//void InteractiveCanvas::hoverMoveEvent(QHoverEvent *event)         {qDebug()<<"hoverMoveEvent(QHoverEvent *event)        "<<event;}
//void InteractiveCanvas::hoverLeaveEvent(QHoverEvent *event)        {qDebug()<<"hoverLeaveEvent(QHoverEvent *event)       "<<event;}

void InteractiveCanvas::paint(QPainter *painter)
{

    QSizeF itemSize = size();

    if(itemSize != _source.size()) {
        _source = QImage(itemSize.width(), itemSize.height(),QImage::Format_ARGB32);
        _source.fill(255); // fill with white
    }


    if (_mode == DRAW) {

        QPainter _internal_painter(&_source);
        QBrush brush(_activeColor);
        QPen pen(brush, _size, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin);

        _internal_painter.setBrush(brush);
        _internal_painter.setPen(pen);
        //_internal_painter.setRenderHint(QPainter::Antialiasing);

        //_internal_painter.drawRect(itemSize.width()/2, 0, 5, itemSize.height());
        //_internal_painter.drawRect(0, itemSize.height()/2, itemSize.width(), 5);

        for (const auto& kv : _strokes) {
            if(kv.second.size() > 1) {
                _internal_painter.drawPolyline(QPolygonF(kv.second));
            }
        }
    }
    else if (_mode == FILL) {

        for (const auto& p : _zones_to_fill) {
            fill(_source, p.x(), p.y(), _activeColor.rgb());
        }
        _zones_to_fill.clear();
    }

    painter->drawImage(0,0,_source);

}

void InteractiveCanvas::clear()
{

    _source.fill(255);
    update();
}

QString InteractiveCanvas::save()
{
    auto dir = QDir(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation));
    auto path = dir.absoluteFilePath("touchpaint-picture.jpg");
   _source.save(path);

   // in order to set the background color to white, we create a new, temporary white image and paint the canvas on top of it.
   QImage tmp(_source.size(),QImage::Format_RGB32);
   tmp.fill(Qt::white);
   QPainter painter(&tmp);
   painter.drawImage(0, 0, _source);
   tmp.save(path, "JPG", 95);
   return path;
}

void InteractiveCanvas::fill(QImage& image, int sx, int sy, QRgb replace_color) {

    if (image.pixel(sx, sy) == replace_color) return;
    QRgb target_color = image.pixel(sx,sy);

    auto pixel_stack = std::stack<point>();
    pixel_stack.push({sx, sy});

    while(!pixel_stack.empty())
    {
        int x, y;
        bool reach_left = false, reach_right = false;

        std::tie(x, y) = pixel_stack.top();
        pixel_stack.pop();

        while(y >= 0 && image.pixel(x,y) == target_color) {
            y--;
        }

        while(y++ < image.height()-1 && image.pixel(x,y) == target_color) {

            image.setPixel(x,y, replace_color);

            if(x > 0) {

                if(image.pixel(x-1,y) == target_color) {

                    if(!reach_left) {
                        pixel_stack.push({x - 1, y});
                        reach_left = true;
                    }
                }
                else if(reach_left) {
                    reach_left = false;
                }
            }

            if(x < image.width()-1) {

                if(image.pixel(x+1,y) == target_color) {
                    if(!reach_right) {
                        pixel_stack.push({x + 1, y});
                        reach_right = true;
                    }
                }
                else if(reach_right) {
                    reach_right = false;
                }
            }
        }
    }

}

