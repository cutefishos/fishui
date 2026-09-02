#ifndef WINDOWHELPER_H
#define WINDOWHELPER_H

#include <QObject>
#include <QWindow>

class WindowHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool wayland READ isWayland CONSTANT)

public:
    explicit WindowHelper(QObject *parent = nullptr);

    bool isWayland() const;

    Q_INVOKABLE void startSystemMove(QWindow *w);
    Q_INVOKABLE void startSystemResize(QWindow *w, Qt::Edges edges);

    Q_INVOKABLE void minimizeWindow(QWindow *w);

    // Whether one of this application's menus is on screen. A menu owns the
    // interaction while it is up, so the panels underneath it must not answer
    // hover with a tooltip.
    Q_INVOKABLE bool popupMenuVisible() const;

};

#endif // WINDOWHELPER_H
