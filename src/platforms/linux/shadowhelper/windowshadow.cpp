#include "windowshadow.h"
#include "waylandshadowmanager.h"

#include <QWindow>

#include <KWayland/Client/shadow.h>
#include <KWayland/Client/surface.h>

using namespace KWayland::Client;

WindowShadow::WindowShadow(QObject *parent) noexcept
    : QObject(parent)
{
}

WindowShadow::~WindowShadow()
{
    delete m_shadow;
}

void WindowShadow::componentComplete()
{
    m_complete = true;
    update();
}

void WindowShadow::setView(QWindow *view)
{
    if (m_view == view)
        return;

    if (m_view)
        m_view->disconnect(this);

    clear();
    m_view = view;

    if (m_view) {
        // Qt tears the wl_surface down when the window is hidden, and the
        // shadow goes with it, so it has to be installed again on every show.
        connect(m_view, &QWindow::visibleChanged, this, &WindowShadow::update);
        // A maximized or fullscreen window has no shadow, and moving to a
        // screen with a different scale needs tiles at the new resolution.
        connect(m_view, &QWindow::windowStateChanged, this, &WindowShadow::update);
        connect(m_view, &QWindow::screenChanged, this, &WindowShadow::update);
    }

    emit viewChanged();
    update();
}

QWindow *WindowShadow::view() const
{
    return m_view;
}

void WindowShadow::setGeometry(const QRect &rect)
{
    if (m_rect == rect)
        return;
    m_rect = rect;
    emit geometryChanged();
}

QRect WindowShadow::geometry() const
{
    return m_rect;
}

void WindowShadow::setRadius(qreal value)
{
    if (m_radius == value)
        return;
    m_radius = value;
    emit radiusChanged();
    update();
}

void WindowShadow::setStrength(qreal strength)
{
    if (m_strength == strength)
        return;
    m_strength = strength;
    emit strengthChanged();
    update();
}

void WindowShadow::clear()
{
    delete m_shadow;
    m_shadow = nullptr;
}

void WindowShadow::update()
{
    if (!m_complete || !m_view)
        return;

    WaylandShadowManager *manager = WaylandShadowManager::instance();
    if (!manager->isValid())
        return;

    // Only exists once the window has been shown; there is nothing to attach
    // a shadow to before that, and update() runs again on visibleChanged.
    Surface *surface = Surface::fromWindow(m_view);
    if (!surface)
        return;

    clear();
    manager->shadowManager()->removeShadow(surface);

    const bool wantsShadow = m_view->isVisible()
                             && !(m_view->windowStates() & (Qt::WindowMaximized | Qt::WindowFullScreen));

    if (wantsShadow) {
        const ShadowTiles &tiles = manager->tiles(m_radius, m_strength, m_view->devicePixelRatio());

        if (tiles.isValid()) {
            m_shadow = manager->shadowManager()->createShadow(surface, this);
            m_shadow->attachTopLeft(tiles.tiles[0]);
            m_shadow->attachTop(tiles.tiles[1]);
            m_shadow->attachTopRight(tiles.tiles[2]);
            m_shadow->attachRight(tiles.tiles[3]);
            m_shadow->attachBottomRight(tiles.tiles[4]);
            m_shadow->attachBottom(tiles.tiles[5]);
            m_shadow->attachBottomLeft(tiles.tiles[6]);
            m_shadow->attachLeft(tiles.tiles[7]);
            m_shadow->setOffsets(tiles.offsets);
            m_shadow->commit();
        }
    }

    // The shadow only becomes visible with the next surface commit. Qt would
    // do one on its own eventually, but not before the next repaint, which
    // may never come for an idle window.
    surface->commit(Surface::CommitFlag::None);
}
