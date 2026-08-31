#ifndef WINDOWSHADOW_H
#define WINDOWSHADOW_H

#include <QObject>
#include <QPointer>
#include <QQmlParserStatus>
#include <QRect>
#include <QTimer>

class QWindow;
class KWindowShadow;

/**
 * Drop shadow for a client side decorated window.
 *
 * KWin never invents a shadow for a window it does not decorate itself, so a
 * frameless window has to render the shadow and hand the tiles over through
 * org_kde_kwin_shadow. The compositor then draws them outside and behind the
 * window, which is the only way to get a shadow that is not clipped by the
 * window's own surface.
 */
class WindowShadow : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QWindow *view READ view WRITE setView NOTIFY viewChanged)
    Q_PROPERTY(QRect geometry READ geometry WRITE setGeometry NOTIFY geometryChanged)
    Q_PROPERTY(qreal radius READ radius WRITE setRadius NOTIFY radiusChanged)
    Q_PROPERTY(qreal strength READ strength WRITE setStrength NOTIFY strengthChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    explicit WindowShadow(QObject *parent = nullptr) noexcept;
    ~WindowShadow() override;

    void classBegin() override {}
    void componentComplete() override;

    void setView(QWindow *view);
    QWindow *view() const;

    void setGeometry(const QRect &rect);
    QRect geometry() const;

    void setRadius(qreal value);
    qreal radius() const { return m_radius; }

    qreal strength() const { return m_strength; }
    void setStrength(qreal strength);

    bool enabled() const { return m_enabled; }
    void setEnabled(bool enabled);

signals:
    void geometryChanged();
    void viewChanged();
    void radiusChanged();
    void strengthChanged();
    void enabledChanged();

private:
    void scheduleUpdate();
    void update();
    void clear();

    QPointer<QWindow> m_view;
    QRect m_rect;
    qreal m_radius = 10;
    qreal m_strength = 1.2;
    bool m_enabled = true;
    bool m_complete = false;
    QTimer m_updateTimer;
    KWindowShadow *m_shadow = nullptr;
};

#endif
