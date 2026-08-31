#ifndef WINDOWSHADOW_H
#define WINDOWSHADOW_H

#include <QObject>
#include <QQmlParserStatus>
#include <QRect>

class QWindow;

class WindowShadow : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QWindow *view READ view WRITE setView NOTIFY viewChanged)
    Q_PROPERTY(QRect geometry READ geometry WRITE setGeometry NOTIFY geometryChanged)
    Q_PROPERTY(qreal radius READ radius WRITE setRadius NOTIFY radiusChanged)
    Q_PROPERTY(qreal strength READ strength WRITE setStrength NOTIFY strengthChanged)

public:
    explicit WindowShadow(QObject *parent = nullptr) noexcept;
    ~WindowShadow() override = default;

    void classBegin() override {}
    void componentComplete() override {}

    void setView(QWindow *view);
    QWindow *view() const;

    void setGeometry(const QRect &rect);
    QRect geometry() const;

    void setRadius(qreal value);
    qreal radius() const { return m_radius; }

    qreal strength() const { return m_strength; }
    void setStrength(qreal strength);

signals:
    void geometryChanged();
    void viewChanged();
    void radiusChanged();
    void strengthChanged();

private:
    QWindow *m_view = nullptr;
    QRect m_rect;
    qreal m_radius = 10;
    qreal m_strength = 1.2;
};

#endif
