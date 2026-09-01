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

class MenuPopupWindow : public QQuickWindow
{
    Q_OBJECT
    Q_PROPERTY(QQuickItem *popupContentItem READ popupContentItem WRITE setPopupContentItem)
    Q_CLASSINFO("DefaultProperty", "popupContentItem")
    Q_PROPERTY(QQuickItem *parentItem READ parentItem WRITE setParentItem NOTIFY parentItemChanged)
    Q_PROPERTY(bool submenu READ submenu NOTIFY parentItemChanged)
    Q_PROPERTY(bool pointerInside READ pointerInside NOTIFY pointerInsideChanged)

public:
    MenuPopupWindow(QQuickWindow *parent = nullptr);

    QQuickItem *popupContentItem() const { return m_contentItem; }
    void setPopupContentItem(QQuickItem *popupContentItem);

    QQuickItem *parentItem() const { return m_parentItem; }
    virtual void setParentItem(QQuickItem *);
    bool submenu() const { return m_parentItem != nullptr; }
    bool pointerInside() const { return m_pointerInside; }
    Q_INVOKABLE bool containsGlobalCursor() const;
    Q_INVOKABLE bool parentItemContainsGlobalCursor() const;
    Q_INVOKABLE bool parentPopupContainsGlobalCursor() const;
    Q_INVOKABLE bool popupChainContainsGlobalCursor() const;
    Q_INVOKABLE bool parentItemHovered() const;

public slots:
    Q_INVOKABLE void show();
    Q_INVOKABLE void dismissPopup();
    Q_INVOKABLE void dismissAllPopups();
    Q_INVOKABLE void updateGeometry();

signals:
    void popupDismissed();
    void geometryChanged();
    void parentItemChanged();
    void pointerInsideChanged();

protected:
    void mousePressEvent(QMouseEvent *) override;
    void mouseReleaseEvent(QMouseEvent *) override;
    void mouseMoveEvent(QMouseEvent *) override;
    bool event(QEvent *) override;

protected slots:
    void applicationStateChanged(Qt::ApplicationState state);

private:
    void setPointerInside(bool inside);
    void setChildPopup(MenuPopupWindow *popup);

    QPointer<QQuickItem> m_parentItem;
    QPointer<QQuickItem> m_contentItem;
    QPointer<MenuPopupWindow> m_parentPopup;
    QPointer<MenuPopupWindow> m_childPopup;
    bool m_mouseMoved;
    bool m_dismissed;
    bool m_pointerInside;
};

#endif
