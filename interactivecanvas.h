#ifndef IMAGEPROCESSING_H
#define IMAGEPROCESSING_H

#include <QObject>
#include <QVector>
#include <map>
#include <QPointF>
#include <QImage>
#include <QQuickPaintedItem>

// the max hue difference between 2 pixels for them to be considered equal
const double HUE_EPSILON = 0.05;

class InteractiveCanvas : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(Mode mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(QColor color MEMBER _activeColor)
    Q_PROPERTY(int size MEMBER _size)

public:
    explicit InteractiveCanvas(QQuickItem *parent = nullptr);

    virtual ~InteractiveCanvas(){}

    enum Mode {DRAW, FILL, ERASE};
    Q_ENUM(Mode)

    void setMode(Mode mode)
    {
        _mode = mode;
        emit modeChanged(mode);
    }

    Mode mode() const
    { return _mode; }

    void paint(QPainter *painter);

    Q_INVOKABLE void clear();

    // save the current picture as a PNG to a writable destination, and return the path
    Q_INVOKABLE QString save();

    Q_INVOKABLE void insertImage(QQuickItem* item);

    virtual void mousePressEvent(QMouseEvent *event);
    virtual void mouseMoveEvent(QMouseEvent *event);
    virtual void mouseReleaseEvent(QMouseEvent *event);
    //virtual void mouseDoubleClickEvent(QMouseEvent *event);
    //virtual void wheelEvent(QWheelEvent *event);
    virtual void touchEvent(QTouchEvent *event);
    //virtual void hoverEnterEvent(QHoverEvent *event);
    //virtual void hoverMoveEvent(QHoverEvent *event);
    //virtual void hoverLeaveEvent(QHoverEvent *event);


signals:
    void modeChanged(Mode);
    void imageInserted(QQuickItem* item);

public slots:

private:

    QImage _source;

    std::map<int, QVector<QPointF>> _strokes;
    QVector<QPointF> _zones_to_fill;

    QColor _activeColor;
    int _size;
    Mode _mode;

    void fill(QImage& image, int sx, int sy, QRgb replace_color);

    QRgb _lastWrongColor; // permits fast path in 'isSameColor' when repeatidly comparing same colors
    inline bool isSameColor(QRgb a, QRgb b, qreal hue_b, qreal lightness_b);
};

#endif // IMAGEPROCESSING_H
