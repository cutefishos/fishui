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

#include "menupopupwindow.h"
#include <QGuiApplication>
#include <QCursor>
#include <QQuickRenderControl>
#include <QQuickItem>
#include <QScreen>
#include <QTimer>

MenuPopupWindow::MenuPopupWindow(QQuickWindow *parent)
    : QQuickWindow(parent)
    , m_parentItem(0)
    , m_contentItem(0)
    , m_parentPopup(0)
    , m_mouseMoved(false)
    , m_dismissed(false)
    , m_pointerInside(false)
{
    setFlags(Qt::Popup);
    setColor(Qt::transparent);
    connect(qApp, SIGNAL(applicationStateChanged(Qt::ApplicationState)),
            this, SLOT(applicationStateChanged(Qt::ApplicationState)));
}

void MenuPopupWindow::applicationStateChanged(Qt::ApplicationState state)
{
    // A submenu is another popup in the same interaction chain. Its show or
    // hide can briefly change the active window without leaving the app.
    // Only the root popup should react to a real application deactivation.
    if (state == Qt::ApplicationActive || m_parentItem || !isVisible())
        return;

    // Showing a submenu can temporarily make the root popup inactive. Delay
    // the decision until Qt has updated focus/transient-parent state, then
    // dismiss only when neither this popup nor one of its child popups owns
    // the interaction.
    QTimer::singleShot(0, this, [this] {
        if (!isVisible() || m_dismissed)
            return;

        if (popupChainContainsGlobalCursor())
            return;

        QWindow *focusWindow = QGuiApplication::focusWindow();
        for (QWindow *window = focusWindow; window; window = window->transientParent()) {
            if (window == this)
                return;
        }

        if (geometry().contains(QCursor::pos()))
            return;

        dismissPopup();
    });
}

void MenuPopupWindow::show()
{
    showAt(QCursor::pos().x(), QCursor::pos().y());
}

void MenuPopupWindow::showAt(int x, int y)
{
    if (!m_contentItem)
        return;

    QPoint pos(x, y);
    const int margin = 6;
    int w = m_contentItem->implicitWidth();
    int h = m_contentItem->implicitHeight();
    int posx = pos.x();
    int posy = pos.y();

    QWindow *pw = transientParent();
    if (!pw && parentItem())
        pw = parentItem()->window();
    if (!pw)
        pw = this;

    QRect g = pw->screen()->availableGeometry();

    const bool isSubmenu = parentItem() && qobject_cast<MenuPopupWindow *>(transientParent());
    const int submenuGap = 6;
    if (isSubmenu) {
        const QPoint itemPos = parentItem()->mapToGlobal(QPointF(0, 0)).toPoint();
        const int rightEdge = itemPos.x() + parentItem()->width();
        posx = rightEdge + submenuGap;
        posy = itemPos.y();

        if (posx + w > g.right() - margin)
            posx = itemPos.x() - w - submenuGap;
    } else if (posx + w > g.right() - margin) {
        posx = g.right() - w - margin;
    }

    posx = qBound(g.left() + margin, posx, g.right() - w - margin);

    m_mouseMoved = false;
    m_dismissed = false;
    if (!isVisible())
        setPointerInside(false);
    posy = qBound(g.top() + margin, posy, g.bottom() - h - margin);

    // Transfer the mouse grab before showing a submenu. Trying to replace a
    // live grab from inside a hover transition can block the event loop on
    // compositors that serialize popup grabs. The Qt::Popup window receives
    // pointer events in its own area without an explicit mouse grab.
    if (isSubmenu && m_parentPopup) {
        m_parentPopup->setMouseGrabEnabled(false);
        m_parentPopup->setKeyboardGrabEnabled(false);
    }

    setGeometry(posx, posy, w, h);

    QQuickWindow::show();
    if (!isSubmenu) {
        // Only the root menu owns the application-level input grabs. A
        // submenu is opened from hover and must not grab input itself.
        setMouseGrabEnabled(true);
        setKeyboardGrabEnabled(true);
    }
}

void MenuPopupWindow::setParentItem(QQuickItem *item)
{
    if (m_parentItem == item)
        return;

    if (m_parentPopup) {
        disconnect(m_parentPopup, nullptr, this, nullptr);
        disconnect(this, nullptr, m_parentPopup, nullptr);
    }

    m_parentItem = item;
    m_parentPopup = nullptr;
    if (m_parentItem) {
        setTransientParent(m_parentItem->window());

        m_parentPopup = qobject_cast<MenuPopupWindow *>(m_parentItem->window());
        if (m_parentPopup) {
            m_parentPopup->setChildPopup(this);
            connect(m_parentPopup, &MenuPopupWindow::popupDismissed,
                    this, &MenuPopupWindow::dismissPopup);
        }
    } else {
        setTransientParent(nullptr);
    }

    emit parentItemChanged();
}

bool MenuPopupWindow::containsGlobalCursor() const
{
    return isVisible() && geometry().contains(QCursor::pos());
}

bool MenuPopupWindow::parentItemContainsGlobalCursor() const
{
    if (!m_parentItem || !m_parentItem->window())
        return false;

    const QPoint topLeft = m_parentItem->mapToGlobal(QPointF(0, 0)).toPoint();
    const QSize size(qCeil(m_parentItem->width()), qCeil(m_parentItem->height()));
    QRect parentRect(topLeft, size);

    // Include the narrow handoff corridor between the parent item and this
    // popup. A native popup cannot receive pointer events in that corridor,
    // so treating it as part of the parent item prevents a false Leave from
    // closing the submenu while the pointer is crossing into it.
    if (isVisible()) {
        if (geometry().left() > parentRect.right())
            parentRect.setRight(geometry().left());
        else if (geometry().right() < parentRect.left())
            parentRect.setLeft(geometry().right());
    }

    return parentRect.contains(QCursor::pos());
}

bool MenuPopupWindow::parentPopupContainsGlobalCursor() const
{
    return m_parentPopup && m_parentPopup->popupChainContainsGlobalCursor();
}

bool MenuPopupWindow::popupChainContainsGlobalCursor() const
{
    if (containsGlobalCursor())
        return true;

    return m_childPopup && m_childPopup->popupChainContainsGlobalCursor();
}

bool MenuPopupWindow::parentItemHovered() const
{
    return m_parentItem && m_parentItem->property("hovered").toBool();
}

void MenuPopupWindow::setPointerInside(bool inside)
{
    if (m_pointerInside == inside)
        return;

    m_pointerInside = inside;
    emit pointerInsideChanged();
}

void MenuPopupWindow::setChildPopup(MenuPopupWindow *popup)
{
    if (!popup || m_childPopup == popup)
        return;

    m_childPopup = popup;
}

void MenuPopupWindow::setPopupContentItem(QQuickItem *contentItem)
{
    if (!contentItem)
        return;

    contentItem->setParentItem(this->contentItem());
    m_contentItem = contentItem;

    connect(contentItem, &QQuickItem::implicitWidthChanged, this, &MenuPopupWindow::updateGeometry);
    connect(contentItem, &QQuickItem::implicitHeightChanged, this, &MenuPopupWindow::updateGeometry);
}

void MenuPopupWindow::dismissPopup()
{
    if (m_dismissed)
        return;

    m_dismissed = true;
    setPointerInside(false);

    // Close transient child popups while this parent surface is still mapped.
    // Unmapping the parent first leaves KWin with a live xdg_popup whose
    // transient parent has already disappeared, which can crash the
    // compositor while it rebuilds the transient window tree.
    emit popupDismissed();

    // Popup windows take both grabs while they are visible.  Releasing only
    // by hiding the window is not sufficient on Wayland/KWin: the hidden
    // popup can keep receiving pointer and keyboard focus, leaving the rest
    // of the desktop unresponsive after a dock context menu is dismissed.
    if (!m_parentItem) {
        setMouseGrabEnabled(false);
        setKeyboardGrabEnabled(false);
    }

    hide();
}

void MenuPopupWindow::dismissAllPopups()
{
    if (m_parentPopup)
        m_parentPopup->dismissAllPopups();

    dismissPopup();
}

void MenuPopupWindow::updateGeometry()
{
    if (!m_contentItem)
        return;

    int w = m_contentItem->implicitWidth();
    int h = m_contentItem->implicitHeight();
    int posx = geometry().x();
    int posy = geometry().y();

    setGeometry(posx, posy, w, h);
}

void MenuPopupWindow::mouseMoveEvent(QMouseEvent *e)
{
    m_mouseMoved = true;
    setPointerInside(QRect(QPoint(), size()).contains(e->position().toPoint()));
    emit mouseMoved();

    QQuickWindow::mouseMoveEvent(e);
}

void MenuPopupWindow::mousePressEvent(QMouseEvent *e)
{
    QRect rect = QRect(QPoint(), size());
    setPointerInside(rect.contains(e->position().toPoint()));
    if (rect.contains(e->pos())) {
        QQuickWindow::mousePressEvent(e);
    } else {
        dismissPopup();
    }
}

void MenuPopupWindow::mouseReleaseEvent(QMouseEvent *e)
{
    QRect rect = QRect(QPoint(), size());
    setPointerInside(rect.contains(e->position().toPoint()));
    if (rect.contains(e->pos())) {
        if (m_mouseMoved) {
            QMouseEvent pe = QMouseEvent(QEvent::MouseButtonPress, e->pos(), e->button(), e->buttons(), e->modifiers());
            QQuickWindow::mousePressEvent(&pe);
            if (!m_dismissed && e->button() != Qt::RightButton) {
                dismissPopup();
                QQuickWindow::mouseReleaseEvent(e);
            }
        }
        m_mouseMoved = true;
    }

    // QQuickWindow::mouseReleaseEvent(e);
    // dismissPopup();
}

bool MenuPopupWindow::event(QEvent *event)
{
    if (event->type() == QEvent::Enter)
        setPointerInside(true);
    else if (event->type() == QEvent::Leave)
        setPointerInside(false);

    //QTBUG-45079
    //This is a workaround for popup menu not being closed when using touch input.
    //Currently mouse synthesized events are not created for touch events which are
    //outside the qquickwindow.

    if (event->type() == QEvent::TouchBegin && !qobject_cast<MenuPopupWindow*>(transientParent())) {
        QRect rect = QRect(QPoint(), size());
        QTouchEvent *touch = static_cast<QTouchEvent*>(event);
        QTouchEvent::TouchPoint point = touch->touchPoints().first();
        if ((point.state() == Qt::TouchPointPressed) && !rect.contains(point.pos().toPoint())) {
          //first default handling
          bool result = QQuickWindow::event(event);
          //now specific broken case
          if (!m_dismissed)
              dismissPopup();
          return result;
        }
    }

    return QQuickWindow::event(event);
}
