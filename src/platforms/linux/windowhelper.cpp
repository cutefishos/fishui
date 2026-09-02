#include "windowhelper.h"

#include <QGuiApplication>

WindowHelper::WindowHelper(QObject *parent)
    : QObject(parent)
{
}

bool WindowHelper::isWayland() const
{
    return true;
}

void WindowHelper::startSystemMove(QWindow *w)
{
    if (w)
        w->startSystemMove();
}

void WindowHelper::startSystemResize(QWindow *w, Qt::Edges edges)
{
    if (w)
        w->startSystemResize(edges);
}

void WindowHelper::minimizeWindow(QWindow *w)
{
    if (w)
        w->showMinimized();
}

bool WindowHelper::popupMenuVisible() const
{
    const auto windows = QGuiApplication::topLevelWindows();
    for (const QWindow *window : windows) {
        if (window->isVisible() && (window->flags() & Qt::Popup) == Qt::Popup)
            return true;
    }

    return false;
}
