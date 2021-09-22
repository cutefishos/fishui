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

#include "windowblur.h"

#include <QApplication>
#include <QPainterPath>
#include <QScreen>
#include <QX11Info>

#include <xcb/xcb.h>
#include <xcb/shape.h>
#include <xcb/xcb_icccm.h>

WindowBlur::WindowBlur(QObject *parent) noexcept
    : QObject(parent)
    , m_view(nullptr)
    , m_enabled(false)
    , m_windowRadius(0.0)
{
}

WindowBlur::~WindowBlur()
{
}

void WindowBlur::classBegin()
{
}

void WindowBlur::componentComplete()
{
    updateBlur();
}

void WindowBlur::setView(QWindow *view)
{
    if (view != m_view) {
        m_view = view;
        updateBlur();
        emit viewChanged();

        connect(m_view, &QWindow::visibleChanged, this, &WindowBlur::onViewVisibleChanged);
    }
}

QWindow* WindowBlur::view() const
{
    return m_view;
}

void WindowBlur::setGeometry(const QRect &rect)
{
    if (rect != m_rect) {
        m_rect = rect;
        updateBlur();
        emit geometryChanged();
    }
}

QRect WindowBlur::geometry() const
{
    return m_rect;
}

void WindowBlur::setEnabled(bool enabled)
{
    if (enabled != m_enabled) {
        m_enabled = enabled;
        updateBlur();
        emit enabledChanged();
    }
}

bool WindowBlur::enabled() const
{
    return m_enabled;
}

void WindowBlur::setWindowRadius(qreal radius)
{
    if (radius != m_windowRadius) {
        m_windowRadius = radius;
        updateBlur();
        emit windowRadiusChanged();
    }
}

qreal WindowBlur::windowRadius() const
{
    return m_windowRadius;
}

void WindowBlur::onViewVisibleChanged(bool visible)
{
    if (visible)
        updateBlur();
}

void WindowBlur::updateBlur()
{
    if (!m_view)
        return;

    xcb_connection_t *c = QX11Info::connection();
    if (!c)
        return;

    const QByteArray effectName = QByteArrayLiteral("_KDE_NET_WM_BLUR_BEHIND_REGION");
    xcb_intern_atom_cookie_t atomCookie = xcb_intern_atom_unchecked(c, false, effectName.length(), effectName.constData());
    QScopedPointer<xcb_intern_atom_reply_t, QScopedPointerPodDeleter> atom(xcb_intern_atom_reply(c, atomCookie, nullptr));
    if (!atom)
        return;

    if (m_enabled) {
        qreal devicePixelRatio = m_view->screen()->devicePixelRatio();
        QPainterPath path;
        path.addRoundedRect(QRectF(QPoint(0, 0), m_view->size() * devicePixelRatio),
                            m_windowRadius * devicePixelRatio,
                            m_windowRadius * devicePixelRatio);
        QVector<uint32_t> data;
        foreach (const QPolygonF &polygon, path.toFillPolygons()) {
            QRegion region = polygon.toPolygon();
            for (auto i = region.begin(); i != region.end(); ++i) {
                data << i->x() << i->y() << i->width() << i->height();
            }
        }

        xcb_change_property(c, XCB_PROP_MODE_REPLACE, m_view->winId(), atom->atom, XCB_ATOM_CARDINAL,
                            32, data.size(), data.constData());

    } else {
        xcb_delete_property(c, m_view->winId(), atom->atom);
    }
}
