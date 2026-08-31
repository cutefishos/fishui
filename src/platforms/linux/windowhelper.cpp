#include "windowhelper.h"

#include <QApplication>
#include <QGuiApplication>

WindowHelper::WindowHelper(QObject *parent)
    : QObject(parent)
    , m_compositing(true)
{
}

bool WindowHelper::compositing() const
{
    return m_compositing;
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
