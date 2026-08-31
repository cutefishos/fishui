#include "windowshadow.h"
#include "waylandshadowmanager.h"

#include <QScreen>
#include <QWindow>

#include <KWindowShadow>
#include <KWindowShadowTile>

WindowShadow::WindowShadow(QObject *parent) noexcept
    : QObject(parent)
{
    m_updateTimer.setSingleShot(true);
    connect(&m_updateTimer, &QTimer::timeout, this, &WindowShadow::update);
}

WindowShadow::~WindowShadow()
{
    clear();
}

void WindowShadow::componentComplete()
{
    m_complete = true;
    scheduleUpdate();
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
        // KWindowShadow implementation recreates it on the next expose.
        connect(m_view, &QWindow::visibleChanged, this, &WindowShadow::scheduleUpdate);
        connect(m_view, &QWindow::screenChanged, this, [this] {
            watchScreen();
            scheduleUpdate();
        });
    }

    watchScreen();

    emit viewChanged();
    scheduleUpdate();
}

QWindow *WindowShadow::view() const
{
    return m_view;
}

void WindowShadow::watchScreen()
{
    QScreen *screen = m_view ? m_view->screen() : nullptr;

    if (m_screen == screen)
        return;

    if (m_screen)
        m_screen->disconnect(this);

    m_screen = screen;

    if (!m_screen)
        return;

    // The tiles are rendered for one device pixel ratio. Changing the scale of
    // an output does not move the window to another screen, so
    // QWindow::screenChanged never fires: without this the shadow would keep
    // the resolution it was first drawn at and the compositor would scale the
    // tiles up into a blurred smear.
    connect(m_screen, &QScreen::physicalDotsPerInchChanged, this, &WindowShadow::scheduleUpdate);
    connect(m_screen, &QScreen::geometryChanged, this, &WindowShadow::scheduleUpdate);
}

void WindowShadow::setRadius(qreal value)
{
    if (m_radius == value)
        return;
    m_radius = value;
    emit radiusChanged();
    clear();
    scheduleUpdate();
}

void WindowShadow::setStrength(qreal strength)
{
    if (m_strength == strength)
        return;
    m_strength = strength;
    emit strengthChanged();
    clear();
    scheduleUpdate();
}

void WindowShadow::setEnabled(bool enabled)
{
    if (m_enabled == enabled)
        return;

    m_enabled = enabled;
    emit enabledChanged();
    if (!m_enabled)
        clear();
    scheduleUpdate();
}

void WindowShadow::scheduleUpdate()
{
    if (!m_updateTimer.isActive())
        m_updateTimer.start();
}

void WindowShadow::clear()
{
    if (m_shadow) {
        m_shadow->destroy();
        delete m_shadow;
    }
    m_shadow = nullptr;
    m_tileScale = 0;
}

void WindowShadow::update()
{
    if (!m_complete || !m_view)
        return;

    if (!m_enabled || !m_view->isVisible()) {
        clear();
        return;
    }

    WaylandShadowManager *manager = WaylandShadowManager::instance();
    if (!manager->isValid() || m_radius <= 0)
        return;

    const qreal scale = m_view->devicePixelRatio();

    // Already up to date. A shadow rendered for another scale has to go.
    if (m_shadow) {
        if (qFuzzyCompare(m_tileScale, scale))
            return;

        clear();
    }

    const ShadowTiles &tiles = manager->tiles(m_radius, m_strength, scale);
    if (!tiles.isValid())
        return;

    m_shadow = new KWindowShadow(this);
    m_shadow->setWindow(m_view);

    const auto createTile = [](const QImage &image) {
        auto tile = KWindowShadowTile::Ptr::create();
        tile->setImage(image);
        return tile;
    };

    m_shadow->setTopLeftTile(createTile(tiles.tiles[0]));
    m_shadow->setTopTile(createTile(tiles.tiles[1]));
    m_shadow->setTopRightTile(createTile(tiles.tiles[2]));
    m_shadow->setRightTile(createTile(tiles.tiles[3]));
    m_shadow->setBottomRightTile(createTile(tiles.tiles[4]));
    m_shadow->setBottomTile(createTile(tiles.tiles[5]));
    m_shadow->setBottomLeftTile(createTile(tiles.tiles[6]));
    m_shadow->setLeftTile(createTile(tiles.tiles[7]));
    m_shadow->setPadding(tiles.offsets);

    if (m_shadow->create())
        m_tileScale = scale;
    else
        clear();
}
