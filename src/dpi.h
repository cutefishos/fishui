#ifndef DPI_H
#define DPI_H

#include <QObject>
#include <QQmlEngine>
#include <QPointer>

class QQuickItem;
class QQuickWindow;

// The device pixel ratio of the window an item lives in.
//
// QML's Screen.devicePixelRatio is QScreen's, which on Wayland is the integer
// wl_output scale: it reports 2 for a 150% output while the window actually
// renders at 1.5. Anything sized from it - a 1/dpr hairline above all - is off
// by a third at fractional scales.
//
// Usage from QML, attached to any Item:
//     Rectangle { border.width: 1 / FishUI.Dpi.ratio }
class Dpi : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal ratio READ ratio NOTIFY ratioChanged)
    QML_ANONYMOUS

public:
    explicit Dpi(QQuickItem *item);

    static Dpi *qmlAttachedProperties(QObject *object);

    qreal ratio() const;

    // Round a length to whole device pixels. Rounding to whole *logical*
    // pixels is not enough at a fractional scale: at 150% a 37px row pitch is
    // 55.5 device px, so every other row lands on a half pixel.
    Q_INVOKABLE qreal snap(qreal value) const;

signals:
    void ratioChanged();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private slots:
    void attachToWindow();

private:
    void setRatio(qreal ratio);

    QQuickItem *m_item = nullptr;
    QPointer<QQuickWindow> m_window;
    qreal m_ratio = 1.0;
};

QML_DECLARE_TYPEINFO(Dpi, QML_HAS_ATTACHED_PROPERTIES)

#endif // DPI_H
