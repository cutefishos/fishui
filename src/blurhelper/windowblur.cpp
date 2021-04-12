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
#include <KWindowEffects>

static QRegion roundedRegion(const QRect &rect, int radius, bool topLeft, bool topRight, bool bottomLeft, bool bottomRight)
{
    QRegion region(rect, QRegion::Rectangle);

    if (topLeft) {
        // Round top-left corner.
        const QRegion topLeftCorner(rect.x(), rect.y(), radius, radius, QRegion::Rectangle);
        const QRegion topLeftRounded(rect.x(), rect.y(), 2 * radius, 2 * radius, QRegion::Ellipse);
        const QRegion topLeftEar = topLeftCorner - topLeftRounded;
        region -= topLeftEar;
    }

    if (topRight) {
        // Round top-right corner.
        const QRegion topRightCorner(
            rect.x() + rect.width() - radius, rect.y(),
            radius, radius, QRegion::Rectangle);
        const QRegion topRightRounded(
            rect.x() + rect.width() - 2 * radius, rect.y(),
            2 * radius, 2 * radius, QRegion::Ellipse);
        const QRegion topRightEar = topRightCorner - topRightRounded;
        region -= topRightEar;
    }

    if (bottomRight) {
        // Round bottom-right corner.
        const QRegion bottomRightCorner(
            rect.x() + rect.width() - radius, rect.y() + rect.height() - radius,
            radius, radius, QRegion::Rectangle);
        const QRegion bottomRightRounded(
            rect.x() + rect.width() - 2 * radius, rect.y() + rect.height() - 2 * radius,
            2 * radius, 2 * radius, QRegion::Ellipse);
        const QRegion bottomRightEar = bottomRightCorner - bottomRightRounded;
        region -= bottomRightEar;
    }

    if (bottomLeft){
        // Round bottom-left corner.
        const QRegion bottomLeftCorner(
            rect.x(), rect.y() + rect.height() - radius,
            radius, radius, QRegion::Rectangle);
        const QRegion bottomLeftRounded(
            rect.x(), rect.y() + rect.height() - 2 * radius,
            2 * radius, 2 * radius, QRegion::Ellipse);
        const QRegion bottomLeftEar = bottomLeftCorner - bottomLeftRounded;
        region -= bottomLeftEar;
    }

    return region;
}

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
    if (m_view) {
        if (m_enabled) {
            QRect rect = QRect(0, 0, m_rect.width(), m_rect.height());
            KWindowEffects::enableBlurBehind(m_view->winId(), true, roundedRegion(rect, m_windowRadius, true, true, true, true));
        } else {
            KWindowEffects::enableBlurBehind(m_view->winId(), false);
        }
    }
}
