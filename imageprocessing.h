#ifndef IMAGEPROCESSING_H
#define IMAGEPROCESSING_H

#include <QObject>
#include <QImage>
#include <QQuickImageProvider>

class FloodFill : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filledImage READ getImage NOTIFY onImageFilled)
    Q_PROPERTY(QString data WRITE setImage MEMBER _data)

public:
    explicit FloodFill(QObject *parent = nullptr);

    virtual ~FloodFill(){}

    Q_INVOKABLE void fill(int x, int y, const QColor& replace_color);

    void setImage(const QString& data);

    const QString& getImage();

signals:
    void onImageFilled();

public slots:

private:
    QString _data;
    bool dirty;
    bool repainting;
    QString _data_filled;
    QImage _source;
    void floodfill_inner(QImage& image, int sx, int sy, QRgb replace_color);
};

#endif // IMAGEPROCESSING_H
