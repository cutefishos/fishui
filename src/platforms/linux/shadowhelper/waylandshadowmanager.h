#ifndef WAYLANDSHADOWMANAGER_H
#define WAYLANDSHADOWMANAGER_H

#include <QMap>
#include <QImage>
#include <QMargins>
#include <QObject>

/**
 * One shadow rendered into the eight tiles KWindowShadow expects, plus the
 * padding that says how far the tiles stick out of the window.
 *
 * KWin does not synthesise a shadow for client side decorated windows: it only
 * composites the tiles a client hands it. The blur is rendered here once and
 * then shared by every window using the same parameters; KWindowShadow owns
 * the shared-memory upload and Wayland protocol objects.
 */
struct ShadowTiles
{
    // topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left.
    QImage tiles[8];
    QMargins offsets;

    bool isValid() const { return !tiles[0].isNull(); }
};

/**
 * Process-wide cache for the images used by KWindowShadow.
 *
 * A single application usually shows many windows with identical shadows, so
 * the rendered tile sets are shared while KWindowShadow owns their native
 * Wayland buffers and protocol objects.
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

private:
    explicit WaylandShadowManager(QObject *parent = nullptr);

    ShadowTiles renderTiles(qreal radius, qreal strength, qreal dpr);

    bool m_valid = false;
    QMap<QString, ShadowTiles> m_cache;
};

#endif // WAYLANDSHADOWMANAGER_H
