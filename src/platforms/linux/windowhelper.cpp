/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     cutefish <cutefishos@foxmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "windowhelper.h"

#include <QApplication>
#include <QGuiApplication>
#include <QtGui/qguiapplication_platform.h>
#include <QCursor>

#include <KX11Extras>
#include <KWindowSystem>

static xcb_connection_t *xcbConnection()
{
    const auto nativeInterface = qGuiApp->nativeInterface<QNativeInterface::QX11Application>();
    return nativeInterface ? nativeInterface->connection() : nullptr;
}

static xcb_window_t xcbRootWindow(xcb_connection_t *connection)
{
    if (!connection)
        return XCB_WINDOW_NONE;

    const xcb_setup_t *setup = xcb_get_setup(connection);
    xcb_screen_iterator_t iterator = xcb_setup_roots_iterator(setup);
    return iterator.data ? iterator.data->root : XCB_WINDOW_NONE;
}

static uint qtEdgesToXcbMoveResizeDirection(Qt::Edges edges)
{
    if (edges == (Qt::TopEdge | Qt::LeftEdge))
        return 0;
    if (edges == Qt::TopEdge)
        return 1;
    if (edges == (Qt::TopEdge | Qt::RightEdge))
        return 2;
    if (edges == Qt::RightEdge)
        return 3;
    if (edges == (Qt::RightEdge | Qt::BottomEdge))
        return 4;
    if (edges == Qt::BottomEdge)
        return 5;
    if (edges == (Qt::BottomEdge | Qt::LeftEdge))
        return 6;
    if (edges == Qt::LeftEdge)
        return 7;

    return 0;
}

WindowHelper::WindowHelper(QObject *parent)
    : QObject(parent)
    , m_moveResizeAtom(0)
    // Wayland always composites client surfaces.  KWindowSystem's X11
    // compositingActive() is intentionally unavailable there, but the QML
    // controls still need the compositor path for rounded/translucent
    // surfaces such as the dock.
    , m_compositing(!KWindowSystem::isPlatformX11())
{
    if (!KWindowSystem::isPlatformX11())
        return;

    // create move-resize atom
    // ref: https://github.com/qt/qtbase/blob/9db7cc79a26ced4997277b5c206ca15949133240/src/plugins/platforms/xcb/qxcbwindow.cpp
    xcb_connection_t *connection = xcbConnection();
    if (!connection)
        return;

    const QString atomName(QStringLiteral("_NET_WM_MOVERESIZE"));
    xcb_intern_atom_cookie_t cookie(xcb_intern_atom(connection, false, atomName.size(), qPrintable(atomName)));
    QScopedPointer<xcb_intern_atom_reply_t> reply(xcb_intern_atom_reply(connection, cookie, nullptr));
    m_moveResizeAtom = reply ? reply->atom : 0;

    onCompositingChanged(KX11Extras::compositingActive());
    connect(KX11Extras::self(), &KX11Extras::compositingChanged, this, &WindowHelper::onCompositingChanged);
}

bool WindowHelper::compositing() const
{
    return m_compositing;
}

bool WindowHelper::isWayland() const
{
    return !KWindowSystem::isPlatformX11();
}

void WindowHelper::startSystemMove(QWindow *w)
{
    if (!KWindowSystem::isPlatformX11()) {
        if (w)
            w->startSystemMove();
        return;
    }

    doStartSystemMoveResize(w, 16);
}

void WindowHelper::startSystemResize(QWindow *w, Qt::Edges edges)
{
    if (!KWindowSystem::isPlatformX11()) {
        if (w)
            w->startSystemResize(edges);
        return;
    }

    doStartSystemMoveResize(w, edges);
}

void WindowHelper::minimizeWindow(QWindow *w)
{
    if (!KWindowSystem::isPlatformX11() || !w)
        return;

    KX11Extras::minimizeWindow(w->winId());
}

void WindowHelper::doStartSystemMoveResize(QWindow *w, int edges)
{
    const qreal dpiRatio = qApp->devicePixelRatio();

    xcb_connection_t *connection = xcbConnection();
    if (!connection || m_moveResizeAtom == XCB_ATOM_NONE)
        return;

    xcb_client_message_event_t xev;
    xev.response_type = XCB_CLIENT_MESSAGE;
    xev.type = m_moveResizeAtom;
    xev.sequence = 0;
    xev.window = w->winId();
    xev.format = 32;
    xev.data.data32[0] = QCursor::pos().x() * dpiRatio;
    xev.data.data32[1] = QCursor::pos().y() * dpiRatio;

    if (edges == 16)
        xev.data.data32[2] = 8; // move
    else
        xev.data.data32[2] = qtEdgesToXcbMoveResizeDirection(Qt::Edges(edges));

    xev.data.data32[3] = XCB_BUTTON_INDEX_1;
    xev.data.data32[4] = 0;
    xcb_ungrab_pointer(connection, XCB_CURRENT_TIME);
    xcb_send_event(connection, false, xcbRootWindow(connection),
                   XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY,
                   (const char *)&xev);
}

void WindowHelper::onCompositingChanged(bool enabled)
{
    if (enabled != m_compositing) {
        m_compositing = enabled;
        emit compositingChanged();
    }
}
