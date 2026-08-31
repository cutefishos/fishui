#ifndef WAYLANDBLURMANAGER_H
#define WAYLANDBLURMANAGER_H

#include <QObject>
#include <QRegion>

namespace KWayland
{
namespace Client
{
class Blur;
class BlurManager;
class Compositor;
class Region;
class Surface;
}
}

/**
 * Process-wide access to org_kde_kwin_blur.
 *
 * KWin blurs whatever a client asks it to blur and nothing else, so a
 * translucent window that wants the desktop behind it out of focus has to hand
 * the compositor a region. The manager is bound once from the registry and
 * shared; the blur object and its region belong to the window, in WindowBlur.
 */
class WaylandBlurManager : public QObject
{
    Q_OBJECT

public:
    static WaylandBlurManager *instance();

    //! Whether the compositor announced the interface at all.
    bool isValid() const;

    //! A blur for @p surface, which the caller keeps for as long as the surface
    //! lives. Deleting it does not clear the blur; removeBlur() does.
    KWayland::Client::Blur *createBlur(KWayland::Client::Surface *surface);
    void removeBlur(KWayland::Client::Surface *surface);

    //! Wraps @p region for the protocol. The compositor copies it when the blur
    //! is committed, so the caller can drop it straight away.
    std::unique_ptr<KWayland::Client::Region> createRegion(const QRegion &region);

Q_SIGNALS:
    //! The interface arrived after a window had already asked for a blur.
    void ready();

private:
    explicit WaylandBlurManager(QObject *parent = nullptr);

    KWayland::Client::BlurManager *m_manager = nullptr;
    KWayland::Client::Compositor *m_compositor = nullptr;
};

#endif // WAYLANDBLURMANAGER_H
