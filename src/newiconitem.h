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
