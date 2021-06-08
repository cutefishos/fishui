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

#include "windowshadow.h"
#include "boxshadowrenderer.h"
#include <QDebug>

enum {
    ShadowNone,
    ShadowSmall,
    ShadowMedium,
    ShadowLarge,
    ShadowVeryLarge
};

const CompositeShadowParams s_shadowParams[] = {
    // None
    CompositeShadowParams(),
    // Small
    CompositeShadowParams(
        QPoint(0, 3),
        ShadowParams(QPoint(0, 0), 16, 0.26),
        ShadowParams(QPoint(0, -2), 8, 0.16)),
    // Medium
    CompositeShadowParams(
        QPoint(0, 4),
        ShadowParams(QPoint(0, 0), 20, 0.24),
        ShadowParams(QPoint(0, -2), 10, 0.14)),
    // Large
    CompositeShadowParams(
        QPoint(0, 5),
        ShadowParams(QPoint(0, 0), 24, 0.22),
        ShadowParams(QPoint(0, -3), 12, 0.12)),
    // Very Large
    CompositeShadowParams(
        QPoint(0, 6),
        ShadowParams(QPoint(0, 0), 32, 0.1),
        ShadowParams(QPoint(0, -3), 16, 0.05))
};

WindowShadow::WindowShadow(QObject *parent) noexcept
    : QObject(parent)
    , m_view(nullptr)
{

}

WindowShadow::~WindowShadow()
{
}

CompositeShadowParams WindowShadow::lookupShadowParams(int shadowSizeEnum)
{
    switch (shadowSizeEnum) {
    case ShadowNone:
        return s_shadowParams[0];
    case ShadowSmall:
        return s_shadowParams[1];
    case ShadowMedium:
        return s_shadowParams[2];
    case ShadowLarge:
        return s_shadowParams[3];
    case ShadowVeryLarge:
        return s_shadowParams[4];
    default:
        // Fallback to the Large size.
        return s_shadowParams[3];
    }
}

void WindowShadow::classBegin()
{
    m_shadowTiles = this->shadowTiles();
}

void WindowShadow::componentComplete()
{
    configureTiles();
}

void WindowShadow::setView(QWindow *view)
{
    if (view != m_view) {
        m_view = view;
        emit viewChanged();
        configureTiles();

        connect(m_view, &QWindow::visibleChanged, this, &WindowShadow::onViewVisibleChanged);
    }
}

QWindow *WindowShadow::view() const 
{
    return m_view;
}

void WindowShadow::setGeometry(const QRect &rect)
{
    if (rect != m_rect) {
        m_rect = rect;
        emit geometryChanged();
        configureTiles();
    }
}

QRect WindowShadow::geometry() const
{
    return m_rect;
}

void WindowShadow::setRadius(qreal value)
{
    if (m_radius != value) {
        m_radius = value;
        emit radiusChanged();

        this->classBegin();

        configureTiles();
    }
}

qreal WindowShadow::strength() const
{
    return m_strength;
}

void WindowShadow::setStrength(qreal strength)
{
    if (m_strength != strength) {
        m_strength = strength;

        this->classBegin();
        configureTiles();

        emit strengthChanged();
    }
}

void WindowShadow::onViewVisibleChanged(bool visible)
{
    if (visible && m_view) {
        configureTiles();
    }
}

void WindowShadow::configureTiles()
{
}

TileSet WindowShadow::shadowTiles()
{
    const qreal frameRadius = m_radius;
    const CompositeShadowParams params = lookupShadowParams(ShadowVeryLarge);

    if (params.isNone())
        return TileSet();

    auto withOpacity = [](const QColor &color, qreal opacity) -> QColor {
        QColor c(color);
        c.setAlphaF(opacity);
        return c;
    };

    const QColor color = Qt::black;
    const qreal strength = m_strength;

    const QSize boxSize = BoxShadowRenderer::calculateMinimumBoxSize(params.shadow1.radius)
        .expandedTo(BoxShadowRenderer::calculateMinimumBoxSize(params.shadow2.radius));

    const qreal dpr = qApp->devicePixelRatio();

    BoxShadowRenderer shadowRenderer;
    shadowRenderer.setBorderRadius(frameRadius);
    shadowRenderer.setBoxSize(boxSize);
    shadowRenderer.setDevicePixelRatio(dpr);

    shadowRenderer.addShadow(params.shadow1.offset, params.shadow1.radius,
        withOpacity(color, params.shadow1.opacity * strength));
    shadowRenderer.addShadow(params.shadow2.offset, params.shadow2.radius,
        withOpacity(color, params.shadow2.opacity * strength));

    QImage shadowTexture = shadowRenderer.render();

    const QRect outerRect(QPoint(0, 0), shadowTexture.size() / dpr);

    QRect boxRect(QPoint(0, 0), boxSize);
    boxRect.moveCenter(outerRect.center());

    // Mask out inner rect.
    QPainter painter(&shadowTexture);
    painter.setRenderHint(QPainter::Antialiasing);

    int Shadow_Overlap = 3;
    const QMargins margins = QMargins(
        boxRect.left() - outerRect.left() - Shadow_Overlap - params.offset.x(),
        boxRect.top() - outerRect.top() - Shadow_Overlap - params.offset.y(),
        outerRect.right() - boxRect.right() - Shadow_Overlap + params.offset.x(),
        outerRect.bottom() - boxRect.bottom() - Shadow_Overlap + params.offset.y());

    painter.setPen(Qt::NoPen);
    painter.setBrush(Qt::black);
    painter.setCompositionMode(QPainter::CompositionMode_DestinationOut);
    painter.drawRoundedRect(
        outerRect - margins,
        frameRadius,
        frameRadius);

    // We're done.
    painter.end();

    const QPoint innerRectTopLeft = outerRect.center();
    TileSet tiles = TileSet(
        QPixmap::fromImage(shadowTexture),
        innerRectTopLeft.x(),
        innerRectTopLeft.y(),
        1, 1);

    return tiles;
}

QMargins WindowShadow::shadowMargins(TileSet shadowTiles) const
{
    const CompositeShadowParams params = lookupShadowParams(ShadowVeryLarge);
    if (params.isNone())
        return QMargins();

    const QSize boxSize = BoxShadowRenderer::calculateMinimumBoxSize(params.shadow1.radius)
        .expandedTo(BoxShadowRenderer::calculateMinimumBoxSize(params.shadow2.radius));

    const QSize shadowSize = BoxShadowRenderer::calculateMinimumShadowTextureSize(boxSize, params.shadow1.radius, params.shadow1.offset)
        .expandedTo(BoxShadowRenderer::calculateMinimumShadowTextureSize(boxSize, params.shadow2.radius, params.shadow2.offset));

    const QRect shadowRect(QPoint(0, 0), shadowSize);

    QRect boxRect(QPoint(0, 0), boxSize);
    boxRect.moveCenter(shadowRect.center());

    int Shadow_Overlap = 4;
    QMargins margins(
        boxRect.left() - shadowRect.left() - Shadow_Overlap - params.offset.x(),
        boxRect.top() - shadowRect.top() - Shadow_Overlap - params.offset.y(),
        shadowRect.right() - boxRect.right() - Shadow_Overlap + params.offset.x(),
        shadowRect.bottom() - boxRect.bottom() - Shadow_Overlap + params.offset.y());

    margins *= shadowTiles.pixmap(0).devicePixelRatio();

    return margins;
}
