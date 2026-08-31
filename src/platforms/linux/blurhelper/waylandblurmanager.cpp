#include "waylandblurmanager.h"

#include <QGuiApplication>

#include <KWayland/Client/blur.h>
#include <KWayland/Client/compositor.h>
#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/region.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

using namespace KWayland::Client;

WaylandBlurManager *WaylandBlurManager::instance()
{
    static WaylandBlurManager *self = new WaylandBlurManager(qApp);
    return self;
}

WaylandBlurManager::WaylandBlurManager(QObject *parent)
    : QObject(parent)
{
    if (!QGuiApplication::platformName().contains(QLatin1String("wayland")))
        return;

    // A compositor whose blur effect is broken paints black where the blurred
    // backdrop belongs, and every translucent window turns into a dark slab.
    // KWin does exactly that on virgl, so leave a way out that does not mean
    // rebuilding: FISHUI_DISABLE_BLUR=1 in the session environment.
    if (qEnvironmentVariableIntValue("FISHUI_DISABLE_BLUR") != 0)
        return;

    ConnectionThread *connection = ConnectionThread::fromApplication(this);
    if (!connection)
        return;

    m_compositor = Compositor::fromApplication(this);

    Registry *registry = new Registry(this);
    registry->create(connection);

    connect(registry, &Registry::blurAnnounced, this, [this, registry](quint32 name, quint32 version) {
        m_manager = registry->createBlurManager(name, version, this);
        Q_EMIT ready();
    });

    registry->setup();

    // The globals are all there by the time the first window is mapped, and one
    // blocking round trip at startup is cheaper than every window having to
    // watch for the manager to turn up.
    connection->roundtrip();
}

bool WaylandBlurManager::isValid() const
{
    return m_manager && m_manager->isValid() && m_compositor && m_compositor->isValid();
}

Blur *WaylandBlurManager::createBlur(Surface *surface)
{
    if (!isValid() || !surface)
        return nullptr;

    // Parented to the surface: Qt drops the wl_surface when the window is
    // hidden, and a blur that outlived it would refer to nothing.
    return m_manager->createBlur(surface, surface);
}

void WaylandBlurManager::removeBlur(Surface *surface)
{
    if (!isValid() || !surface)
        return;

    m_manager->removeBlur(surface);
}

std::unique_ptr<Region> WaylandBlurManager::createRegion(const QRegion &region)
{
    if (!isValid())
        return nullptr;

    return m_compositor->createRegion(region);
}
