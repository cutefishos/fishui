#ifndef NEWICONITEM_H
#define NEWICONITEM_H

#include <QQuickPaintedItem>
#include <QPixmap>
#include <QPixmapCache>
#include <QIcon>

class IconItemSource;
class NewIconItem : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QVariant source READ source WRITE setSource NOTIFY sourceChanged)

public:
    NewIconItem(QQuickItem *parent = nullptr);

    void setSource(const QVariant &source);
    QVariant source() const;

    void paint(QPainter *painter) override;

    Q_INVOKABLE void updateIcon();

signals:
    void sourceChanged();

protected:
    void loadPixmap();
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private:
    QVariant m_source;

    QIcon m_icon;
    QImage m_image;

    QString m_iconName;
    QPixmap m_iconPixmap;
};

#endif // NEWICONITEM_H
