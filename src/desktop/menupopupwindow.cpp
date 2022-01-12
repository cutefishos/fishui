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
#include <QQuickRenderControl>
#include <QQuickItem>
#include <QScreen>

MenuPopupWindow::MenuPopupWindow(QQuickWindow *parent)
    : QQuickWindow(parent)
    , m_parentItem(0)
    , m_contentItem(0)
    , m_mouseMoved(false)
    , m_dismissed(false)
{
    setFlags(Qt::Popup);
    setColor(Qt::transparent);
    connect(qApp, SIGNAL(applicationStateChanged(Qt::ApplicationState)),
            this, SLOT(applicationStateChanged(Qt::ApplicationState)));
}

void MenuPopupWindow::applicationStateChanged(Qt::ApplicationState state)
{
    if (state != Qt::ApplicationActive)
        dismissPopup();
}

void MenuPopupWindow::show()
{
    QPoint pos = QCursor::pos();
    const int margin = 6;
    int w = m_contentItem->implicitWidth();
    int h = m_contentItem->implicitHeight() + 16;
    int posx = pos.x();
    int posy = pos.y();

    QWindow *pw = transientParent();
    if (!pw && parentItem())
        pw = parentItem()->window();
    if (!pw)
        pw = this;

    QRect g = pw->screen()->availableGeometry();

    if (posx + w > g.right()) {
        if (qobject_cast<MenuPopupWindow *>(transientParent())) {
            // reposition submenu window on the parent menu's left side
            int submenuOverlap = pw->x() + pw->width() - posx;
            posx -= pw->width() + w - 2 * submenuOverlap;
        } else {
            posx = g.right() - w - margin;
        }
    } else {
        posx = qMax(posx, g.left() + margin);
    }

    m_mouseMoved = false;
    m_dismissed = false;

    posy = qBound(g.top(), posy, g.bottom() - h - margin);

    setGeometry(posx, posy, w, h);

    QQuickWindow::show();
    setMouseGrabEnabled(true);
    setKeyboardGrabEnabled(true);
}

void MenuPopupWindow::setParentItem(QQuickItem *item)
{
    m_parentItem = item;
    if (m_parentItem)
        setTransientParent(m_parentItem->window());
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
    m_dismissed = true;
    emit popupDismissed();
    hide();
}

void MenuPopupWindow::updateGeometry()
{
    int w = m_contentItem->implicitWidth();
    int h = m_contentItem->implicitHeight() + 16;
    int posx = geometry().x();
    int posy = geometry().y();

    setGeometry(posx, posy, w, h);
}

void MenuPopupWindow::mouseMoveEvent(QMouseEvent *e)
{
    m_mouseMoved = true;

    QQuickWindow::mouseMoveEvent(e);
}

void MenuPopupWindow::mousePressEvent(QMouseEvent *e)
{
    QRect rect = QRect(QPoint(), size());
    if (rect.contains(e->pos())) {
        QQuickWindow::mousePressEvent(e);
    } else {
        dismissPopup();
    }
}

void MenuPopupWindow::mouseReleaseEvent(QMouseEvent *e)
{
    QRect rect = QRect(QPoint(), size());
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
