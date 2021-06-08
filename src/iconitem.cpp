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

#include "iconitem.h"
#include <QDebug>
#include <QPainter>
#include <QPaintEngine>
#include <QGuiApplication>
#include <QQuickWindow>
#include <QPixmap>
#include <QImageReader>
#include <QPixmapCache>

#include "managedtexturenode.h"

template<class T>
typename std::enable_if <!std::is_integral<T>(), bool>::type almost_equal(T x, T y, int ulp)
{
    return std::abs(x - y) <std::numeric_limits<T>::epsilon() * std::abs(x + y) * ulp
           || std::abs(x - y) <std::numeric_limits<T>::min();
}

class IconItemSource
{
public:
    explicit IconItemSource(IconItem *iconItem)
        : m_iconItem(iconItem)
    {
    }
    virtual ~IconItemSource()
    {
    }

    virtual bool isValid() const = 0;
    virtual const QSize size() const = 0;
    virtual QPixmap pixmap(const QSize &size) = 0;

protected:
    QQuickWindow *window() {
        return m_iconItem->window();
    }

    IconItem *m_iconItem;
};

class NullSource : public IconItemSource
{
public:
    explicit NullSource(IconItem *iconItem)
        : IconItemSource(iconItem)
    {
    }

    bool isValid() const override
    {
        return false;
    }

    const QSize size() const override
    {
        return QSize();
    }

    QPixmap pixmap(const QSize &size) override
    {
        Q_UNUSED(size)
        return QPixmap();
    }
};

class QIconSource : public IconItemSource
{
public:
    explicit QIconSource(const QIcon &icon, IconItem *iconItem)
        : IconItemSource(iconItem)
    {
        m_icon = icon;
    }

    bool isValid() const override
    {
        return !m_icon.isNull();
    }

    const QSize size() const override
    {
        return QSize();
    }

    QPixmap pixmap(const QSize &size) override
    {
        QPixmap result = m_icon.pixmap(window(), m_icon.actualSize(size));
        return result;
    }

private:
    QIcon m_icon;
};

class QImageSource : public IconItemSource
{
public:
    explicit QImageSource(const QImage &imageIcon, IconItem *iconItem)
        : IconItemSource(iconItem)
    {
        m_imageIcon = imageIcon;
    }

    bool isValid() const override
    {
        return !m_imageIcon.isNull();
    }

    const QSize size() const override
    {
        const QSize s = m_imageIcon.size();
        if (s.isValid()) {
            return s;
        }

        return QSize();
    }

    QPixmap pixmap(const QSize &size) override
    {
        Q_UNUSED(size)
        return QPixmap::fromImage(m_imageIcon);
    }

private:
    QImage m_imageIcon;
};

class SvgSource : public IconItemSource
{
public:
    explicit SvgSource(const QString &sourceString, IconItem *iconItem)
        : IconItemSource(iconItem)
    {
        m_reader.setFileName(sourceString);
    }

    bool isValid() const override {
        return m_reader.canRead();
    }

    const QSize size() const override {
        return QSize();
    }

    QPixmap pixmap(const QSize &size) override {
        m_reader.setScaledSize(size * devicePixelRatio());
        return QPixmap::fromImage(m_reader.read());
    }

private:
    qreal devicePixelRatio() {
        return window() ? window()->devicePixelRatio() : qApp->devicePixelRatio();
    }

    QImageReader m_reader;
    QString m_svgIconName;
};

IconItem::IconItem(QQuickItem *parent)
    : QQuickItem(parent)
    , m_iconItemSource(new NullSource(this))
    , m_active(false)
    , m_animated(false)
    , m_roundToIconSize(true)
    , m_textureChanged(false)
    , m_sizeChanged(false)
{
    setFlag(ItemHasContents, true);
    setSmooth(true);
}

void IconItem::setSource(const QVariant &source)
{
    if (source == m_source) {
        return;
    }

    const bool oldValid = isValid();

    m_source = source;
    QString sourceString = source.toString();

    if (source.canConvert<QIcon>() && !source.value<QIcon>().name().isEmpty()) {
        sourceString = source.value<QIcon>().name();
    }

    if (!sourceString.isEmpty()) {
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
                QIcon icon = QIcon(localFile);
                m_iconItemSource.reset(new QIconSource(icon, this));
            } else {
                QImage imageIcon = QImage(localFile);
                m_iconItemSource.reset(new QImageSource(imageIcon, this));
            }
        } else {
//            if (sourceString.startsWith("qrc:/"))
//                m_iconItemSource.reset(new SvgSource(sourceString.remove(0, 3), this));
//            else if (sourceString.startsWith(":/"))
//                m_iconItemSource.reset(new SvgSource(sourceString, this));

            if (!m_iconItemSource->isValid()) {
                // if we started with a QIcon use that.
                QIcon icon = source.value<QIcon>();
                if (icon.isNull()) {
                    icon = QIcon::fromTheme(sourceString, QIcon::fromTheme("application-x-desktop"));
                }
                m_iconItemSource.reset(new QIconSource(icon, this));
            }
        }

    } else if (source.canConvert<QIcon>()) {
        m_iconItemSource.reset(new QIconSource(source.value<QIcon>(), this));
    } else if (source.canConvert<QImage>()) {
        m_iconItemSource.reset(new QImageSource(source.value<QImage>(), this));
    } else {
        m_iconItemSource.reset(new NullSource(this));
    }

    if (width() > 0 && height() > 0) {
        schedulePixmapUpdate();
    }

    updateImplicitSize();

    emit sourceChanged();

    if (isValid() != oldValid) {
        Q_EMIT validChanged();
    }
}

QVariant IconItem::source() const
{
    return m_source;
}

void IconItem::updateImplicitSize()
{
    if (m_iconItemSource->isValid()) {
        const QSize s = m_iconItemSource->size();

        if (s.isValid()) {
            if (!m_implicitWidthSetByUser && !m_implicitHeightSetByUser) {
                setImplicitSize(s.width(), s.height());
            } else if (!m_implicitWidthSetByUser) {
                setImplicitWidth(s.width());
            } else if (!m_implicitHeightSetByUser) {
                setImplicitHeight(s.height());
            }

            return;
        }
    }

    // Fall back to initializing implicit size to the Dialog size.
    const int implicitSize = 16;

    if (!m_implicitWidthSetByUser && !m_implicitHeightSetByUser) {
        setImplicitSize(implicitSize, implicitSize);
    } else if (!m_implicitWidthSetByUser) {
        setImplicitWidth(implicitSize);
    } else if (!m_implicitHeightSetByUser) {
        setImplicitHeight(implicitSize);
    }
}

bool IconItem::isValid() const
{
    return m_iconItemSource->isValid();
}

int IconItem::paintedWidth() const
{
    return boundingRect().size().toSize().width();
}

int IconItem::paintedHeight() const
{
    return boundingRect().size().toSize().height();
}

void IconItem::updateIcon()
{
    updatePolish();
}

void IconItem::updatePolish()
{
    QQuickItem::updatePolish();
    loadPixmap();
}

QSGNode *IconItem::updatePaintNode(QSGNode *oldNode, QQuickItem::UpdatePaintNodeData *updatePaintNodeData)
{
    Q_UNUSED(updatePaintNodeData)

    if (m_iconPixmap.isNull() || width() == 0.0 || height() == 0.0) {
        delete oldNode;
        return nullptr;
    }

    ManagedTextureNode *textureNode = dynamic_cast<ManagedTextureNode *>(oldNode);

    if (!textureNode || m_textureChanged) {
        delete oldNode;
        textureNode = new ManagedTextureNode;
        textureNode->setTexture(QSharedPointer<QSGTexture>(window()->createTextureFromImage(m_iconPixmap.toImage(), QQuickWindow::TextureCanUseAtlas)));
        m_sizeChanged = true;
        m_textureChanged = false;
    }
    textureNode->setFiltering(smooth() ? QSGTexture::Linear : QSGTexture::Nearest);

    if (m_sizeChanged) {
        const QSize newSize = QSize(paintedWidth(), paintedHeight());
        const QRect destRect(QPointF(boundingRect().center() - QPointF(newSize.width(), newSize.height()) / 2).toPoint(), newSize);
        textureNode->setRect(destRect);
        m_sizeChanged = false;
    }
    return textureNode;
}

void IconItem::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value)
{
    QQuickItem::itemChange(change, value);
}

void IconItem::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    if (newGeometry.size() != oldGeometry.size()) {
        m_sizeChanged = true;

        if (newGeometry.width() > 1 && newGeometry.height() > 1) {
            schedulePixmapUpdate();
        } else {
            update();
        }

        const auto oldSize = qMin(oldGeometry.size().width(), oldGeometry.size().height());
        const auto newSize = qMin(newGeometry.size().width(), newGeometry.size().height());

        if (!almost_equal(oldSize, newSize, 2)) {
            emit paintedSizeChanged();
        }
    }

    QQuickItem::geometryChanged(newGeometry, oldGeometry);
}

void IconItem::componentComplete()
{
    QQuickItem::componentComplete();
    schedulePixmapUpdate();
}

void IconItem::schedulePixmapUpdate()
{
    polish();
}

void IconItem::loadPixmap()
{
    if (!isComponentComplete()) {
        return;
    }

    QPixmapCache::clear();

    int size = qMin(qRound(width()), qRound(height()));
    QPixmap result;

    if (size <= 0) {
        m_iconPixmap = QPixmap();
        update();
        return;
    }

    if (m_iconItemSource->isValid()) {
        result = m_iconItemSource->pixmap(QSize(size * qApp->devicePixelRatio(),
                                                size * qApp->devicePixelRatio()));
        result.setDevicePixelRatio(qApp->devicePixelRatio());
    } else {
        m_iconPixmap = QPixmap();
        update();
        return;
    }

    m_oldIconPixmap = m_iconPixmap;
    m_iconPixmap = result;
    m_textureChanged = true;

    update();
}
