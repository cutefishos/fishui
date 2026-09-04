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

#ifndef MENUPOPUPWINDOW_H
#define MENUPOPUPWINDOW_H

#include <QQuickWindow>
#include <QQuickItem>
#include <QPointer>
#include <QElapsedTimer>

class MenuPopupWindow : public QQuickWindow
{
    Q_OBJECT
    Q_PROPERTY(QQuickItem *popupContentItem READ popupContentItem WRITE setPopupContentItem)
    Q_CLASSINFO("DefaultProperty", "popupContentItem")
    Q_PROPERTY(QQuickItem *parentItem READ parentItem WRITE setParentItem NOTIFY parentItemChanged)
    Q_PROPERTY(bool submenu READ submenu NOTIFY parentItemChanged)
    Q_PROPERTY(bool pointerInside READ pointerInside NOTIFY pointerInsideChanged)
    Q_PROPERTY(int contentTopMargin READ contentTopMargin WRITE setContentTopMargin NOTIFY contentTopMarginChanged)
    // How tall the popup may become on the screen it will appear on.
    Q_PROPERTY(int availableHeight READ availableHeight NOTIFY availableHeightChanged)
    // The work area to keep the popup inside. Wayland tells a client nothing
    // about other clients' panels, so QScreen::availableGeometry() is the
    // whole output there and a menu would open under the status bar and the
    // dock. An application that does know - the shell reserves those struts
    // itself - sets the area here; an invalid rect falls back to the screen.
    Q_PROPERTY(QRect availableGeometry READ availableGeometry WRITE setAvailableGeometry NOTIFY availableGeometryChanged)

public:
    MenuPopupWindow(QQuickWindow *parent = nullptr);
    ~MenuPopupWindow() override;

    QQuickItem *popupContentItem() const { return m_contentItem; }
    void setPopupContentItem(QQuickItem *popupContentItem);

    QQuickItem *parentItem() const { return m_parentItem; }
    virtual void setParentItem(QQuickItem *);
    bool submenu() const { return m_parentItem != nullptr; }
    bool pointerInside() const { return m_pointerInside; }
    // Distance between the popup's top edge and the top of its first row.
    // A submenu is placed with this offset removed so that its first row
    // lines up with the parent item instead of the popup frame.
    int contentTopMargin() const { return m_contentTopMargin; }
    int availableHeight() const;
    QRect availableGeometry() const;
    void setAvailableGeometry(const QRect &geometry);
    void setContentTopMargin(int margin);
    Q_INVOKABLE bool containsGlobalCursor() const;
    Q_INVOKABLE bool parentItemContainsGlobalCursor() const;
    Q_INVOKABLE bool parentPopupContainsGlobalCursor() const;
    Q_INVOKABLE bool popupChainContainsGlobalCursor() const;
    Q_INVOKABLE bool parentItemHovered() const;
    Q_INVOKABLE QPointF globalCursorPos() const;

public slots:
    Q_INVOKABLE void show();
    Q_INVOKABLE void showAt(int x, int y);
    Q_INVOKABLE void dismissPopup();
    Q_INVOKABLE void dismissAllPopups();
    Q_INVOKABLE void updateGeometry();

signals:
    void popupDismissed();
    // Carries the global cursor position: while a menu is open it owns the
    // pointer grab, so anything else that needs to follow the cursor (a menu
    // bar switching between its menus, say) can only learn about it here.
    void mouseMoved(const QPointF &globalPos);
    void geometryChanged();
    void parentItemChanged();
    void pointerInsideChanged();
    void contentTopMarginChanged();
    void availableHeightChanged();
    void availableGeometryChanged();
    // Key events are reported per window rather than left to Qt Quick's
    // focus handling: opening a submenu popup moves the window focus off the
    // menu the user is navigating, and an item-level Keys handler then stops
    // receiving anything at all.
    void keyPressed(int key, int modifiers);

protected:
    void keyPressEvent(QKeyEvent *) override;
    void mousePressEvent(QMouseEvent *) override;
    void mouseReleaseEvent(QMouseEvent *) override;
    void mouseMoveEvent(QMouseEvent *) override;
    bool event(QEvent *) override;

protected slots:
    void applicationStateChanged(Qt::ApplicationState state);

private:
    bool isSubmenuPopup() const;
    QRect availableScreenGeometry() const;
    MenuPopupWindow *rootPopup() const;
    QPoint popupPosition(const QPoint &requested, const QSize &size) const;
    void setPointerInside(bool inside);
    void setChildPopup(MenuPopupWindow *popup);
    void unmap();
    void takeDownOtherPopups();
    static void takeDown(MenuPopupWindow *popup);

    QPointer<QQuickItem> m_parentItem;
    QPointer<QQuickItem> m_contentItem;
    QPointer<MenuPopupWindow> m_parentPopup;
    QPointer<MenuPopupWindow> m_childPopup;
    bool m_mouseMoved;
    bool m_dismissed;
    // A dismissed popup is only unmapped once the current event delivery is
    // over, so that a menu bar switching menus keeps the surface it has.
    bool m_hidePending = false;
    bool m_pointerInside;
    int m_contentTopMargin;
    QRect m_availableGeometry;
    bool m_pressed;
    QElapsedTimer m_shownTimer;

    // Every popup of this process, so that a menu about to be mapped can take
    // down a chain that is still on screen.
    static QList<MenuPopupWindow *> s_popups;
};

#endif
