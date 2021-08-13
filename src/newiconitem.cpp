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

#include "newiconitem.h"

#include <QQuickWindow>
#include <QGuiApplication>
#include <QImageReader>
#include <QPainter>
#include <QIcon>

NewIconItem::NewIconItem(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    setFlag(ItemHasContents, true);
    setSmooth(false);
}

void NewIconItem::setSource(const QVariant &source)
{
    if (source == m_source) {
        return;
    }

    m_source = source;
    QString sourceString = source.toString();

    if (source.canConvert<QIcon>() && !source.value<QIcon>().name().isEmpty()) {
        sourceString = source.value<QIcon>().name();
    }

    QString localFile;
    if (sourceString.startsWith(QLatin1String("file:"))) {
        localFile = QUrl(sourceString).toLocalFile();
    } else if (sourceString.startsWith(QLatin1Char('/'))) {
        localFile = sourceString;
    } else if (sourceString.startsWith("qrc:/")) {
        localFile = sourceString.remove(0, 3);
    } else if (sourceString.startsWith(":/")) {
        localFile = sourceString;
    }

    if (!localFile.isEmpty()) {
        if (sourceString.endsWith(QLatin1String(".svg"))
            || sourceString.endsWith(QLatin1String(".svgz"))
            || sourceString.endsWith(QLatin1String(".ico"))) {
            m_icon = QIcon(localFile);
            m_iconName.clear();
            m_image = QImage();
        } else {
            m_image = QImage(localFile);
            m_iconName.clear();
            m_icon = QIcon();
        }
    } else if (source.canConvert<QIcon>()) {
        m_icon = source.value<QIcon>();
        m_iconName.clear();
        m_image = QImage();
    } else if (source.canConvert<QImage>()) {
        m_image = source.value<QImage>();
        m_iconName.clear();
        m_icon = QIcon();
    }  else if (source.canConvert<QPixmap>()) {
        m_image = source.value<QPixmap>().toImage();
        m_iconName.clear();
        m_icon = QIcon();
    } else {
        // From icon theme.
        m_icon = QIcon();
        m_image = QImage();
        m_iconName = sourceString;
    }

    if (width() > 0 && height() > 0) {
        loadPixmap();
    }

    emit sourceChanged();
}

QVariant NewIconItem::source() const
{
    return m_source;
}

void NewIconItem::paint(QPainter *painter)
{
    if (m_iconPixmap.isNull())
        return;

    painter->setRenderHints(QPainter::SmoothPixmapTransform);
    painter->drawPixmap(contentsBoundingRect().toRect(), m_iconPixmap);
}

void NewIconItem::updateIcon()
{
    loadPixmap();
}

void NewIconItem::loadPixmap()
{
    if (!isComponentComplete()) {
        return;
    }

    QSize size = QSize(width(), height());
    QPixmap result;

    if (size.width() < 0 ||
            size.height() < 0) {
        m_iconPixmap = QPixmap();
        update();
        return;
    }

    if (!m_iconName.isEmpty()) {
        QIcon icon = QIcon::fromTheme(m_iconName);

        if (icon.isNull())
            icon = QIcon::fromTheme("application-x-desktop");

        result = icon.pixmap(size * qApp->devicePixelRatio());
    } else if (!m_icon.isNull()) {
        result = m_icon.pixmap(window(), size * qApp->devicePixelRatio());
    } else if (!m_image.isNull()) {
        result = QPixmap::fromImage(m_image);
    } else {
        m_iconPixmap = QPixmap();
        update();
        return;
    }

    m_iconPixmap = result;
    update();
}

void NewIconItem::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    QQuickPaintedItem::geometryChanged(newGeometry, oldGeometry);

    if (newGeometry.width() > 0 && newGeometry.height() > 0) {
        loadPixmap();
    }
}
