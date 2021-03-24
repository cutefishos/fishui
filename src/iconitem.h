/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     cutefish <cutefishos@foxmail.com>
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

#include <QQuickItem>
#include <QIcon>
#include <QImage>
#include <QPixmap>

#include <QSharedPointer>

class IconItemSource;
class IconItem : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QVariant source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(bool valid READ isValid NOTIFY validChanged)
    Q_PROPERTY(int paintedWidth READ paintedWidth NOTIFY paintedSizeChanged)
    Q_PROPERTY(int paintedHeight READ paintedHeight NOTIFY paintedSizeChanged)

public:
    explicit IconItem(QQuickItem *parent = nullptr);

    void setSource(const QVariant &source);
    QVariant source() const;

    void updateImplicitSize();

    bool isValid() const;

    int paintedWidth() const;
    int paintedHeight() const;

    Q_INVOKABLE void updateIcon();

    void updatePolish() override;
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *updatePaintNodeData) override;

    void itemChange(ItemChange change, const ItemChangeData &value) override;
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry) override;

    void componentComplete() override;

signals:
    void overlaysChanged();
    void activeChanged();
    void sourceChanged();
    void animatedChanged();
    void roundToIconSizeChanged();
    void validChanged();
    void colorGroupChanged();
    void paintedSizeChanged();
    void statusChanged();
    void implicitHeightChanged2();
    void implicitWidthChanged2();

private slots:
    void schedulePixmapUpdate();

private:
    void loadPixmap();

private:
    QSharedPointer<IconItemSource> m_iconItemSource;
    QVariant m_source;

    bool m_active;
    bool m_animated;
    bool m_roundToIconSize;

    bool m_textureChanged;
    bool m_sizeChanged;
    bool m_allowNextAnimation;
    bool m_blockNextAnimation;
    bool m_implicitHeightSetByUser;
    bool m_implicitWidthSetByUser;

    QPixmap m_iconPixmap;
    QPixmap m_oldIconPixmap;
};

#endif // ICONITEM_H
