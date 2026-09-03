#include "dpi.h"

#include <QQuickItem>
#include <QQuickWindow>
#include <QGuiApplication>
#include <QEvent>
#include <cmath>
#include <QDebug>

Dpi::Dpi(QQuickItem *item)
    : QObject(item)
    , m_item(item)
{
    if (!m_item)
        setRatio(qGuiApp ? qGuiApp->devicePixelRatio() : 1.0);

    if (!m_item)
        return;

    connect(m_item, &QQuickItem::windowChanged, this, &Dpi::attachToWindow);
    attachToWindow();
}

Dpi *Dpi::qmlAttachedProperties(QObject *object)
{
    // Attaching to a non-Item (a Timer, a QtObject) would otherwise silently
    // report 1.0, so look for an Item to hang off before giving up.
    for (QObject *o = object; o; o = o->parent()) {
        if (auto *item = qobject_cast<QQuickItem *>(o))
            return new Dpi(item);

        if (auto *window = qobject_cast<QQuickWindow *>(o))
            return new Dpi(window->contentItem());
    }

    qWarning() << "FishUI.Dpi: attached to" << object
               << "which is not inside an Item; falling back to the application ratio.";

    return new Dpi(nullptr);
}

qreal Dpi::ratio() const
{
    return m_ratio;
}

qreal Dpi::snap(qreal value) const
{
    if (m_ratio <= 0)
        return value;

    return std::round(value * m_ratio) / m_ratio;
}

void Dpi::attachToWindow()
{
    QQuickWindow *window = m_item ? m_item->window() : nullptr;

    if (window == m_window)
        return;

    if (m_window)
        m_window->removeEventFilter(this);

    m_window = window;

    if (m_window) {
        // QWindow has no devicePixelRatioChanged signal; the event is the only
        // notification a live scale change gives.
        m_window->installEventFilter(this);
        setRatio(m_window->effectiveDevicePixelRatio());
    } else {
        setRatio(qGuiApp ? qGuiApp->devicePixelRatio() : 1.0);
    }
}

bool Dpi::eventFilter(QObject *watched, QEvent *event)
{
    if (watched == m_window &&
            (event->type() == QEvent::DevicePixelRatioChange ||
             event->type() == QEvent::ScreenChangeInternal)) {
        setRatio(m_window->effectiveDevicePixelRatio());
    }

    return QObject::eventFilter(watched, event);
}

void Dpi::setRatio(qreal ratio)
{
    if (qFuzzyCompare(m_ratio, ratio))
        return;

    m_ratio = ratio;
    emit ratioChanged();
}
