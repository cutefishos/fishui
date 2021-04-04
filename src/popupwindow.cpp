#include "popupwindow.h"
#include <QGuiApplication>
#include <QQuickRenderControl>
#include <QQuickItem>
#include <QScreen>

PopupWindow::PopupWindow(QQuickWindow *parent)
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

void PopupWindow::applicationStateChanged(Qt::ApplicationState state)
{
    if (state != Qt::ApplicationActive)
        dismissPopup();
}

void PopupWindow::show()
{
    QPoint pos = QCursor::pos();
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
        if (qobject_cast<PopupWindow *>(transientParent())) {
            // reposition submenu window on the parent menu's left side
            int submenuOverlap = pw->x() + pw->width() - posx;
            posx -= pw->width() + w - 2 * submenuOverlap;
        } else {
            posx = g.right() - w;
        }
    } else {
        posx = qMax(posx, g.left());
    }

    posy = qBound(g.top(), posy, g.bottom() - h);

    setGeometry(posx, posy, w, h);

    QQuickWindow::show();
    setMouseGrabEnabled(true);
    setKeyboardGrabEnabled(true);
}

void PopupWindow::setParentItem(QQuickItem *item)
{
    m_parentItem = item;
    if (m_parentItem)
        setTransientParent(m_parentItem->window());
}

void PopupWindow::setPopupContentItem(QQuickItem *contentItem)
{
    if (!contentItem)
        return;

    contentItem->setParentItem(this->contentItem());
    m_contentItem = contentItem;
}

void PopupWindow::dismissPopup()
{
    m_dismissed = true;
    emit popupDismissed();
    hide();
}

void PopupWindow::mouseMoveEvent(QMouseEvent *e)
{
    QQuickWindow::mouseMoveEvent(e);
}

void PopupWindow::mousePressEvent(QMouseEvent *e)
{
    QRect rect = QRect(QPoint(), size());
    if (rect.contains(e->pos())) {
        QQuickWindow::mousePressEvent(e);
    } else {
        dismissPopup();
    }
}

void PopupWindow::mouseReleaseEvent(QMouseEvent *e)
{
    QQuickWindow::mouseReleaseEvent(e);
    dismissPopup();
}

bool PopupWindow::event(QEvent *event)
{
    //QTBUG-45079
    //This is a workaround for popup menu not being closed when using touch input.
    //Currently mouse synthesized events are not created for touch events which are
    //outside the qquickwindow.

    if (event->type() == QEvent::TouchBegin && !qobject_cast<PopupWindow*>(transientParent())) {
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
