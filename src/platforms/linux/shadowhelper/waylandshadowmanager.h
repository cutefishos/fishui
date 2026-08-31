#ifndef WAYLANDSHADOWMANAGER_H
#define WAYLANDSHADOWMANAGER_H

#include <QMap>
#include <QMarginsF>
#include <QObject>

#include <KWayland/Client/buffer.h>

namespace KWayland
{
namespace Client
{
class ConnectionThread;
class Registry;
class ShadowManager;
class ShmPool;
}
}

/**
 * One shadow rendered into the eight tiles org_kde_kwin_shadow expects, plus
 * the offsets that say how far the tiles stick out of the window.
 *
 * KWin does not synthesise a shadow for client side decorated windows: it only
 * composites the tiles a client hands it, the same way the X11 protocol takes
 * _KDE_NET_WM_SHADOW. So the blur is rendered here, uploaded to shared memory
 * once, and then shared by every window using the same parameters.
 */
struct ShadowTiles
{
    // topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left.
    KWayland::Client::Buffer::Ptr tiles[8];
    QMarginsF offsets;

    bool isValid() const { return !tiles[0].isNull(); }
};

/**
 * Process wide access to the KWin shadow protocol.
 *
 * The registry, the shm pool and the rendered tile sets are shared, because a
 * single application usually shows many windows with identical shadows and
 * every tile set costs shared memory on both sides of the connection.
 */
class WaylandShadowManager : public QObject
{
    Q_OBJECT

public:
    static WaylandShadowManager *instance();

    bool isValid() const;

    /**
     * Returns the tile set for the given parameters, rendering and uploading
     * it on first use.
     */
    const ShadowTiles &tiles(qreal radius, qreal strength, qreal dpr);

    KWayland::Client::ShadowManager *shadowManager() const { return m_shadowManager; }

private:
    explicit WaylandShadowManager(QObject *parent = nullptr);

    ShadowTiles renderTiles(qreal radius, qreal strength, qreal dpr);

    KWayland::Client::ConnectionThread *m_connection = nullptr;
    KWayland::Client::Registry *m_registry = nullptr;
    KWayland::Client::ShadowManager *m_shadowManager = nullptr;
    KWayland::Client::ShmPool *m_shmPool = nullptr;

    QMap<QString, ShadowTiles> m_cache;
};

#endif // WAYLANDSHADOWMANAGER_H
