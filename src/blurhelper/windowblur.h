#ifndef WINDOWBLUR_H
#define WINDOWBLUR_H

#include <QApplication>
#include <QObject>
#include <QQmlEngine>
#include <QQmlParserStatus>
#include <QRect>
#include <QWindow>
#include <QVector>

class WindowBlur : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QWindow *view READ view WRITE setView NOTIFY viewChanged)
    Q_PROPERTY(QRect geometry READ geometry WRITE setGeometry NOTIFY geometryChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(qreal windowRadius READ windowRadius WRITE setWindowRadius NOTIFY windowRadiusChanged)
    Q_INTERFACES(QQmlParserStatus)

public:
    WindowBlur(QObject *parent = nullptr) noexcept;
    ~WindowBlur() override;

    void classBegin() override;
    void componentComplete() override;

    void setView(QWindow *view);
    QWindow *view() const;

    void setGeometry(const QRect &rect);
    QRect geometry() const;

    void setEnabled(bool enabled);
    bool enabled() const;

    void setWindowRadius(qreal radius);
    qreal windowRadius() const;

private slots:
    void onViewVisibleChanged(bool);

private:
    void updateBlur();

signals:
    void viewChanged();
    void enabledChanged();
    void windowRadiusChanged();
    void geometryChanged();

private:
    QWindow *m_view;
    QRect m_rect;
    bool m_enabled;
    qreal m_windowRadius;
};

#endif
