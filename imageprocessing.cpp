#include <stack>

#include <QDebug>
#include <QByteArray>
#include <QBuffer>

#include "imageprocessing.h"

typedef std::pair<int,int> point;

FloodFill::FloodFill(QObject *parent) : QObject(parent), dirty(false), repainting(false), _data_filled("")
{

}

void FloodFill::fill(int sx, int sy, const QColor& replace_color)
{
    QImage _toFill(_source); // shallow copy using Qt's implicit sharing semantics

    if (_toFill.width() == 0 || _toFill.height() == 0) return;

   floodfill_inner(_toFill, sx, sy, replace_color.rgb());

   _source = _toFill;
   dirty=true;
   emit onImageFilled();

   _source.save("/tmp/text.png");
}

void FloodFill::setImage(const QString &data)
{
    QByteArray base64Data = data.mid(22).toUtf8();
    //QImage tmp;
    _source.loadFromData(QByteArray::fromBase64(base64Data), "PNG");

    //_source = tmp.scaledToWidth(tmp.width()/tmp.devicePixelRatioF());
    //_source = tmp.scaledToWidth(tmp.width()/2);
}

const QString &FloodFill::getImage()
{

    if (repainting) return _data_filled;

    if(dirty) {
        repainting = true;

        QByteArray ba;
        QBuffer bu(&ba);

        _source.save(&bu, "PNG");

        qDebug() << "cpp: " << _source.width() << "x" << _source.height();

        _data_filled = "data:image/png;base64," + ba.toBase64();

        dirty=false;
        repainting = false;
    }

    return _data_filled;
}




void FloodFill::floodfill_inner(QImage& image, int sx, int sy, QRgb replace_color) {

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

