#include "waylandshadowmanager.h"
#include "boxshadowrenderer.h"

#include <QGuiApplication>
#include <QImage>
#include <QPainter>

namespace {

struct ShadowParams
{
    ShadowParams() = default;
    ShadowParams(const QPoint &offset, int radius, qreal opacity)
        : offset(offset)
        , radius(radius)
        , opacity(opacity)
    {}

    QPoint offset;
    int radius = 0;
    qreal opacity = 0;
};

struct CompositeShadowParams
{
    CompositeShadowParams() = default;
    CompositeShadowParams(const QPoint &offset, const ShadowParams &shadow1, const ShadowParams &shadow2)
        : offset(offset)
        , shadow1(shadow1)
        , shadow2(shadow2)
    {}

    bool isNone() const { return qMax(shadow1.radius, shadow2.radius) == 0; }

    QPoint offset;
    ShadowParams shadow1;
    ShadowParams shadow2;
};

// Two stacked blurs, the same shape Breeze uses: a wide ambient shadow plus a
// tighter one lifted upwards, so the window looks lit from above. The
// opacities are of the blurred black that is composited *behind* the window,
// so they read far lighter on screen than the numbers suggest: at a tenth of
// this the shadow measured about 5% darker than the wallpaper next to it,
// which is to say invisible.
const CompositeShadowParams s_shadowParams(
    QPoint(0, 6),
    ShadowParams(QPoint(0, 0), 32, 0.5),
    ShadowParams(QPoint(0, -3), 16, 0.25));

// How far the shadow reaches under the window. Without an overlap the tiles
// stop exactly at the window edge and antialiasing leaves a bright seam there.
const int ShadowOverlap = 4;

QColor withOpacity(const QColor &color, qreal opacity)
{
    QColor c(color);
    c.setAlphaF(opacity);
    return c;
}

} // namespace

WaylandShadowManager *WaylandShadowManager::instance()
{
    static WaylandShadowManager *self = new WaylandShadowManager(qApp);
    return self;
}

WaylandShadowManager::WaylandShadowManager(QObject *parent)
    : QObject(parent)
{
    m_valid = QGuiApplication::platformName().contains(QLatin1String("wayland"));
}

bool WaylandShadowManager::isValid() const
{
    return m_valid;
}

const ShadowTiles &WaylandShadowManager::tiles(qreal radius, qreal strength, qreal dpr)
{
    const QString key = QStringLiteral("%1|%2|%3").arg(radius).arg(strength).arg(dpr);

    auto it = m_cache.find(key);
    if (it == m_cache.end())
        it = m_cache.insert(key, renderTiles(radius, strength, dpr));

    return *it;
}

ShadowTiles WaylandShadowManager::renderTiles(qreal radius, qreal strength, qreal dpr)
{
    ShadowTiles result;

    if (!isValid() || s_shadowParams.isNone())
        return result;

    const CompositeShadowParams &params = s_shadowParams;

    // The box has to be large enough for the blur to reach full strength in
    // the middle of every edge, otherwise the stretched tiles are too light.
    const QSize boxSize = BoxShadowRenderer::calculateMinimumBoxSize(params.shadow1.radius)
                              .expandedTo(BoxShadowRenderer::calculateMinimumBoxSize(params.shadow2.radius));

    BoxShadowRenderer renderer;
    renderer.setBorderRadius(radius);
    renderer.setBoxSize(boxSize);
    renderer.setDevicePixelRatio(dpr);
    renderer.addShadow(params.shadow1.offset, params.shadow1.radius,
                       withOpacity(Qt::black, params.shadow1.opacity * strength));
    renderer.addShadow(params.shadow2.offset, params.shadow2.radius,
                       withOpacity(Qt::black, params.shadow2.opacity * strength));

    QImage texture = renderer.render();
    if (texture.isNull())
        return result;

    const QRect outerRect(QPoint(0, 0), texture.size() / dpr);

    QRect boxRect(QPoint(0, 0), boxSize);
    boxRect.moveCenter(outerRect.center());

    // innerRect is the window itself: padding is exactly what the protocol
    // calls the shadow offsets, the amount the shadow sticks out on each side.
    // ShadowOverlap makes the shadow shape a little smaller than the window so
    // its own edge disappears under the window instead of ending on a seam,
    // and params.offset shifts the window up inside the texture so the shadow
    // falls downwards.
    const QMargins padding(boxRect.left() - outerRect.left() - ShadowOverlap - params.offset.x(),
                           boxRect.top() - outerRect.top() - ShadowOverlap - params.offset.y(),
                           outerRect.right() - boxRect.right() - ShadowOverlap + params.offset.x(),
                           outerRect.bottom() - boxRect.bottom() - ShadowOverlap + params.offset.y());
    const QRect innerRect = outerRect - padding;

    // Punch out the window itself: the compositor draws the tiles behind the
    // window, and an opaque patch under a translucent window would show. The
    // hole has the window's own corner radius so the shadow follows it.
    QPainter painter(&texture);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.setPen(Qt::NoPen);
    painter.setBrush(Qt::black);
    painter.setCompositionMode(QPainter::CompositionMode_DestinationOut);
    painter.drawRoundedRect(innerRect, radius, radius);
    painter.end();

    // Slice into the eight tiles the protocol wants, cutting at the centre of
    // the texture and leaving a single pixel in the middle. The cut has to sit
    // where the blur is already uniform along the edge, which the minimum box
    // size guarantees only at the centre: cutting closer to the corners would
    // leave part of the rounded corner in the edge tiles, and the compositor
    // stretches those across the whole window.
    const int unit = qMax(1, qRound(dpr));
    const int left = qRound(outerRect.center().x() * dpr);
    const int top = qRound(outerRect.center().y() * dpr);
    const int right = texture.width() - left - unit;
    const int bottom = texture.height() - top - unit;

    if (left <= 0 || top <= 0 || right <= 0 || bottom <= 0)
        return result;

    const QRect rects[8] = {
        QRect(0, 0, left, top),                             // topLeft
        QRect(left, 0, unit, top),                          // top
        QRect(left + unit, 0, right, top),                  // topRight
        QRect(left + unit, top, right, unit),               // right
        QRect(left + unit, top + unit, right, bottom),      // bottomRight
        QRect(left, top + unit, unit, bottom),              // bottom
        QRect(0, top + unit, left, bottom),                 // bottomLeft
        QRect(0, top, left, unit)                           // left
    };

    for (int i = 0; i < 8; ++i) {
        result.tiles[i] = texture.copy(rects[i]);

        if (result.tiles[i].isNull())
            return ShadowTiles();
    }

    result.offsets = padding;

    return result;
}
