/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     revenmartin <revenmartin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef ICONITEM_H
#define ICONITEM_H

#include <QQuickPaintedItem>
#include <QPixmap>
#include <QPixmapCache>
#include <QIcon>
#include <QColor>

class IconItemSource;
class IconItem : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QVariant source READ source WRITE setSource NOTIFY sourceChanged)
    // An invalid colour (the default) paints the icon as it is.
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)

public:
    IconItem(QQuickItem *parent = nullptr);

    void setSource(const QVariant &source);
    QVariant source() const;

    void setColor(const QColor &color);
    QColor color() const;

    void paint(QPainter *painter) override;

    Q_INVOKABLE void updateIcon();

signals:
    void sourceChanged();
    void colorChanged();

protected:
    void loadPixmap();
    void componentComplete() override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    QSGNode *updatePaintNode(QSGNode *node, UpdatePaintNodeData *data) override;

    // The scale the icon must be rasterised at: the window's, not the
    // application's, so a second screen with another scale is handled too.
    qreal scaleFactor() const;

private:
    QVariant m_source;

    QIcon m_icon;
    QImage m_image;

    QString m_iconName;
    QColor m_color;
    QPixmap m_iconPixmap;
    qreal m_pixmapScale = 0;
};

#endif // ICONITEM_H
