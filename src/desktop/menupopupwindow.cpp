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
#include <QCoreApplication>
#include <QCursor>
#include <QKeyEvent>
#include <QQuickRenderControl>
#include <QQuickItem>
#include <QScreen>
#include <QTimer>
#include <QtMath>

// Distance kept between a popup and the screen edges.
static const int kScreenMargin = 6;
// A release that arrives this soon after the menu opened still belongs to
// the press that opened it, the way a short click-and-hold does on macOS.
static const int kOpeningPressMs = 200;

// A submenu sits against the menu it belongs to, overlapping its border
// slightly so the two frames read as one connected menu.
static const int kSubmenuOverlap = 2;

MenuPopupWindow::MenuPopupWindow(QQuickWindow *parent)
    : QQuickWindow(parent)
    , m_parentItem(0)
    , m_contentItem(0)
    , m_parentPopup(0)
    , m_mouseMoved(false)
    , m_dismissed(false)
    , m_pointerInside(false)
    , m_contentTopMargin(0)
    , m_pressed(false)
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

bool MenuPopupWindow::isSubmenuPopup() const
{
    return m_parentItem && qobject_cast<MenuPopupWindow *>(transientParent());
}

MenuPopupWindow *MenuPopupWindow::rootPopup() const
{
    const MenuPopupWindow *popup = this;
    while (popup->m_parentPopup)
        popup = popup->m_parentPopup;

    return const_cast<MenuPopupWindow *>(popup);
}

QRect MenuPopupWindow::availableGeometry() const
{
    // A submenu is placed inside the same work area as the menu it belongs
    // to, which is the one the application configured.
    const MenuPopupWindow *root = rootPopup();
    if (root->m_availableGeometry.isValid())
        return root->m_availableGeometry;

    return availableScreenGeometry();
}

void MenuPopupWindow::setAvailableGeometry(const QRect &geometry)
{
    if (m_availableGeometry == geometry)
        return;

    m_availableGeometry = geometry;
    emit availableGeometryChanged();
    emit availableHeightChanged();

    if (isVisible())
        updateGeometry();
}

QRect MenuPopupWindow::availableScreenGeometry() const
{
    const QWindow *pw = transientParent();
    if (!pw && m_parentItem)
        pw = m_parentItem->window();
    if (!pw)
        pw = this;

    const QScreen *screen = pw->screen();
    if (!screen)
        screen = QGuiApplication::primaryScreen();

    return screen ? screen->availableGeometry() : QRect();
}

QPoint MenuPopupWindow::popupPosition(const QPoint &requested, const QSize &size) const
{
    const QRect g = availableGeometry();
    if (!g.isValid())
        return requested;

    int posx = requested.x();
    int posy = requested.y();

    if (isSubmenuPopup()) {
        const QPoint itemPos = m_parentItem->mapToGlobal(QPointF(0, 0)).toPoint();

        // Attach the submenu to the parent menu's frame rather than to the
        // item inside it: the item stops short of the frame by the menu
        // padding, which would push the submenu that much further away.
        const QRect parentFrame = m_parentPopup ? m_parentPopup->geometry()
                                                : QRect(itemPos, QSize(qCeil(m_parentItem->width()),
                                                                       qCeil(m_parentItem->height())));
        posx = parentFrame.right() + 1 - kSubmenuOverlap;

        // Line the first row of the submenu up with the parent item. The
        // popup starts with its own vertical padding, so the frame has to
        // begin that much higher than the item it belongs to.
        posy = itemPos.y() - m_contentTopMargin;

        // Not enough room on the right: mirror the submenu to the other
        // side of the parent menu instead of letting it run off screen.
        if (posx + size.width() > g.right() - kScreenMargin)
            posx = parentFrame.left() + kSubmenuOverlap - size.width();
    } else if (posx + size.width() > g.right() - kScreenMargin) {
        posx = g.right() - size.width() - kScreenMargin;
    }

    // A submenu taller than the space below the parent item is moved up so
    // that its last row stays on screen; the alignment is only kept when it
    // actually fits.
    if (posy + size.height() > g.bottom() - kScreenMargin)
        posy = g.bottom() - kScreenMargin - size.height();

    // qBound() requires min <= max, which no longer holds once the popup is
    // larger than the screen. Clamping the top-left edge alone keeps the
    // start of the menu reachable in that case.
    posx = qMax(g.left() + kScreenMargin, qMin(posx, g.right() - kScreenMargin - size.width()));
    posy = qMax(g.top() + kScreenMargin, posy);

    return QPoint(posx, posy);
}

int MenuPopupWindow::availableHeight() const
{
    const QRect g = availableGeometry();
    return g.isValid() ? g.height() - kScreenMargin * 2 : 0;
}

void MenuPopupWindow::setContentTopMargin(int margin)
{
    if (m_contentTopMargin == margin)
        return;

    m_contentTopMargin = margin;
    emit contentTopMarginChanged();

    if (isVisible())
        updateGeometry();
}

void MenuPopupWindow::showAt(int x, int y)
{
    if (!m_contentItem)
        return;

    // The popup may be about to appear on another screen than the one it was
    // last sized for.
    emit availableHeightChanged();

    const int w = qCeil(m_contentItem->implicitWidth());
    const int h = qCeil(m_contentItem->implicitHeight());

    m_mouseMoved = false;
    m_dismissed = false;
    m_pressed = false;
    m_shownTimer.start();
    if (!isVisible())
        setPointerInside(false);

    const QPoint pos = popupPosition(QPoint(x, y), QSize(w, h));
    const int posx = pos.x();
    const int posy = pos.y();

    const bool isSubmenu = isSubmenuPopup();

    // Hand the keyboard grab over before showing a submenu. Trying to replace
    // a live grab from inside a hover transition can block the event loop on
    // compositors that serialize popup grabs.
    //
    // Claiming the parent's submenu slot here rather than only when the
    // parent item is assigned also covers a submenu that is shown again
    // after the pointer has been to a sibling in the meantime.
    if (isSubmenu && m_parentPopup) {
        m_parentPopup->setChildPopup(this);
        m_parentPopup->setKeyboardGrabEnabled(false);
    }

    setGeometry(posx, posy, w, h);

    QQuickWindow::show();
    if (!isSubmenu) {
        // Only the root menu owns the keyboard grab; a submenu is opened from
        // hover and must not grab input itself.
        //
        // The pointer is deliberately left ungrabbed. A Qt::Popup window is
        // already an xdg_popup with the compositor's own grab, which is what
        // dismisses the menu on a click outside it. Asking for the client
        // side grab on top of that redirects every pointer event to this
        // window, so the surface underneath - the panel holding the menu bar
        // that opened this menu - stops seeing hover altogether and a menu bar
        // can no longer switch menus under the pointer.
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

QPointF MenuPopupWindow::globalCursorPos() const
{
    return QCursor::pos();
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

    // A menu may only ever have one submenu on screen. Popups have to be
    // taken down innermost first, so the submenu that is being replaced has
    // to go before the new one is mapped: leaving both up and letting the
    // older one time out afterwards destroys them out of order, and the
    // compositor answers that by dismissing the whole popup chain - the menu
    // disappears from under the pointer.
    if (m_childPopup && m_childPopup->isVisible())
        m_childPopup->dismissPopup();

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

    // A root popup holds the keyboard grab while it is visible. Releasing it
    // only by hiding the window is not sufficient on Wayland/KWin: the hidden
    // popup can keep receiving keyboard focus, leaving the rest of the desktop
    // unresponsive after a dock context menu is dismissed.
    if (!m_parentItem)
        setKeyboardGrabEnabled(false);

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

    const int w = qCeil(m_contentItem->implicitWidth());
    const int h = qCeil(m_contentItem->implicitHeight());

    // Re-run the placement: a popup that grew after it was shown would
    // otherwise keep a position computed for its old size, which both
    // breaks the submenu alignment and lets the menu run off screen.
    const QPoint pos = popupPosition(geometry().topLeft(), QSize(w, h));

    setGeometry(pos.x(), pos.y(), w, h);
}

void MenuPopupWindow::keyPressEvent(QKeyEvent *e)
{
    emit keyPressed(e->key(), int(e->modifiers()));
    e->accept();
}

void MenuPopupWindow::mouseMoveEvent(QMouseEvent *e)
{
    m_mouseMoved = true;
    setPointerInside(QRect(QPoint(), size()).contains(e->position().toPoint()));
    emit mouseMoved(e->globalPosition());

    QQuickWindow::mouseMoveEvent(e);
}

void MenuPopupWindow::mousePressEvent(QMouseEvent *e)
{
    const QRect rect(QPoint(), size());
    const bool inside = rect.contains(e->position().toPoint());
    setPointerInside(inside);

    if (inside) {
        m_pressed = true;
        QQuickWindow::mousePressEvent(e);
        return;
    }

    // A press that lands on one of our own popups is part of the same menu
    // interaction. Compositors that keep the pointer grab on the menu that
    // owns it deliver such a press here, and dismissing on it would close
    // the menu instead of letting the submenu item handle the click.
    if (popupChainContainsGlobalCursor())
        return;

    dismissPopup();
}

void MenuPopupWindow::mouseReleaseEvent(QMouseEvent *e)
{
    const QRect rect(QPoint(), size());
    const bool inside = rect.contains(e->position().toPoint());
    const bool pressedHere = m_pressed;
    m_pressed = false;

    setPointerInside(inside);

    if (!inside) {
        m_mouseMoved = true;
        return;
    }

    // Activate on a plain click (press and release in this popup) and on the
    // press-drag-release gesture that starts on whatever opened the menu.
    // The release of the very press that opened the menu is ignored: it has
    // neither a press of its own here nor any pointer movement.
    if (!pressedHere && (!m_mouseMoved || m_shownTimer.elapsed() < kOpeningPressMs)) {
        m_mouseMoved = true;
        return;
    }

    if (!pressedHere) {
        // Press-drag-release: the item under the cursor never saw a press,
        // so it cannot turn this release into a click. Replay the pair as a
        // normal press followed by a release. Both have to leave the current
        // delivery - Qt Quick ignores a pointer event sent while another one
        // is being handled - and the release must be built only once the
        // press has been delivered, otherwise it carries no press state and
        // the item never sees it.
        const QPointF local = e->position();
        const QPointF scene = e->scenePosition();
        const QPointF global = e->globalPosition();
        const Qt::MouseButton button = e->button();
        const Qt::KeyboardModifiers mods = e->modifiers();
        QMouseEvent *press = new QMouseEvent(QEvent::MouseButtonPress, local, scene, global,
                                             button, button, mods);
        QCoreApplication::postEvent(this, press);
        QTimer::singleShot(0, this, [this, local, scene, global, button, mods] {
            QMouseEvent re(QEvent::MouseButtonRelease, local, scene, global,
                           button, Qt::NoButton, mods);
            QCoreApplication::sendEvent(this, &re);
        });
        m_mouseMoved = true;
        return;
    }

    // Deliver the release before closing anything: hiding the popup cancels
    // the item's mouse grab, and a release that arrives after that never
    // becomes a click, so the action would silently not run.
    QQuickWindow::mouseReleaseEvent(e);

    m_mouseMoved = true;

    if (m_dismissed || e->button() == Qt::RightButton)
        return;

    // Clicking an item that owns a submenu opens it instead of choosing
    // anything, so the menu chain has to stay on screen.
    if (submenuOpenedAt(e->globalPosition().toPoint()))
        return;

    dismissPopup();
}

bool MenuPopupWindow::submenuOpenedAt(const QPoint &globalPos) const
{
    if (!m_childPopup || !m_childPopup->isVisible())
        return false;

    const QQuickItem *item = m_childPopup->parentItem();
    if (!item || !item->window())
        return false;

    const QRect itemRect(item->mapToGlobal(QPointF(0, 0)).toPoint(),
                         QSize(qCeil(item->width()), qCeil(item->height())));

    return itemRect.contains(globalPos);
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
