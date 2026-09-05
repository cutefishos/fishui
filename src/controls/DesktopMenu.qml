/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     revenmartin <revenmartin@gmail.com>
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
 
import QtQuick 2.15
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import FishUI 1.0 as FishUI

FishUI.MenuPopupWindow {
    id: control

    property bool blurEnabled: FishUI.Theme.blurEnabled

    default property alias content : _contentItem.content

    popupContentItem: _contentItem

    // Lets the popup align its first row with the item that opened it.
    contentTopMargin: _contentItem.verticalContentMargin

    FishUI.MenuSurface {
        id: _contentItem

        view: control
        blurEnabled: control.blurEnabled && !control.submenu
        // A menu with more rows than the screen is tall scrolls instead of
        // running off the edge.
        maxHeight: control.availableHeight > 0 ? control.availableHeight : 0
    }

    // ------------------------------------------------------------------
    // Keyboard navigation
    //
    // Only the root popup takes the keyboard grab, so every key event of an
    // open menu chain is delivered to it. It forwards the event to the
    // deepest open submenu - the one the user is actually looking at -
    // instead of relying on window focus, which no compositor hands to a
    // submenu popup that was opened from hover.
    // ------------------------------------------------------------------

    // Row that the keyboard highlights, as an index into menuRows().
    property alias currentIndex: _contentItem.currentIndex

    // The menu is being driven from the keyboard: the pointer is somewhere
    // else entirely, so the hover-based submenu dismissal has to stand down
    // until the pointer moves again.
    property bool keyboardNavigation: false

    // Left in a root menu and Right on a row without a submenu are not ours
    // to handle: a menu bar uses them to walk to the neighbouring menu.
    signal keyNavigationLeft()
    signal keyNavigationRight()

    function menuRows() {
        return _contentItem.menuRows()
    }

    function currentRow() {
        return _contentItem.currentRow()
    }

    function setCurrentIndex(index) {
        _contentItem.setCurrentIndex(index)
    }

    function moveCurrentIndex(step) {
        _contentItem.moveCurrentIndex(step)
    }

    // The deepest open popup of this chain; it is the one keys apply to.
    function leafMenu() {
        var rows = control.menuRows()
        for (var i = 0; i < rows.length; ++i) {
            var child = rows[i].childMenu
            if (child && child.visible)
                return child.leafMenu()
        }
        return control
    }

    function closeSubmenus() {
        var rows = control.menuRows()
        for (var i = 0; i < rows.length; ++i) {
            var child = rows[i].childMenu
            if (child && child.visible) {
                child.closeSubmenus()
                child.dismissPopup()
            }
        }
    }

    // Hand the menu back to the pointer: drop the keyboard highlight of the
    // whole chain so that the hovered row is the only highlighted one.
    function clearKeyboardState() {
        control.keyboardNavigation = false
        var rows = control.menuRows()
        for (var i = 0; i < rows.length; ++i) {
            var child = rows[i].childMenu
            if (child && child.visible)
                child.clearKeyboardState()
        }
        control.setCurrentIndex(-1)
    }

    function openCurrentSubmenu() {
        var row = control.currentRow()
        if (!row || !row.childMenu)
            return false

        control.keyboardNavigation = true
        row.childMenu.keyboardNavigation = true
        row.childMenu.parentItem = row
        row.childMenu.popupSubMenu()
        row.childMenu.moveCurrentIndex(1)
        return true
    }

    function activateCurrentRow() {
        var row = control.currentRow()
        if (!row || !row.enabled)
            return

        if (row.childMenu) {
            control.openCurrentSubmenu()
            return
        }

        row.triggered()
    }

    // Key events are reported by the popup window itself. Whichever popup of
    // the chain the compositor happens to give them to, they are handled by
    // the one that is open deepest - the menu the user is looking at.
    onWheelMoved: function (angleDelta, pixelDelta) {
        _contentItem.scrollByWheel(angleDelta, pixelDelta)
    }

    onKeyPressed: function (key, modifiers) {
        var menu = control.leafMenu()
        if (menu !== control) {
            menu.handleKey(key)
            return
        }

        control.handleKey(key)
    }

    function handleKey(key) {
        switch (key) {
        case Qt.Key_Down:
            control.keyboardNavigation = true
            control.moveCurrentIndex(1)
            break
        case Qt.Key_Up:
            control.keyboardNavigation = true
            control.moveCurrentIndex(-1)
            break
        case Qt.Key_Right:
            if (control.openCurrentSubmenu())
                break
            if (control.submenu)
                break
            control.keyNavigationRight()
            break
        case Qt.Key_Left:
            if (control.submenu) {
                control.dismissPopup()
                break
            }
            control.keyNavigationLeft()
            break
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Space:
            control.activateCurrentRow()
            break
        case Qt.Key_Home:
            control.keyboardNavigation = true
            control.setCurrentIndex(-1)
            control.moveCurrentIndex(1)
            break
        case Qt.Key_End:
            control.keyboardNavigation = true
            control.setCurrentIndex(-1)
            control.moveCurrentIndex(-1)
            break
        case Qt.Key_Escape:
            if (control.submenu)
                control.dismissPopup()
            else
                control.dismissAllPopups()
            break
        }
    }

    // Real pointer movement over the menu wins over the keyboard highlight.
    // Movement elsewhere is ignored: while a menu is open it owns the pointer
    // grab and sees every motion on the screen, including the jitter of a
    // pointer that is nowhere near the menu.
    onMouseMoved: {
        if (control.popupChainContainsGlobalCursor())
            control.clearKeyboardState()

        control.updateSubmenuHover()
    }

    // Close a hover-opened submenu as soon as the pointer has left both it and
    // the row it hangs off. The poll timer below would only notice at its next
    // tick, which is what made a row with a submenu let go of its highlight
    // later than every other row.
    function updateSubmenuHover() {
        var rows = control.menuRows()
        for (var i = 0; i < rows.length; ++i) {
            var child = rows[i].childMenu
            if (!child || !child.visible || child.keyboardNavigation)
                continue

            child.updateSubmenuHover()

            if (child.containsGlobalCursor() || child.pointerInside)
                continue

            // Also true in the handoff corridor between the row and its popup.
            if (child.parentItemContainsGlobalCursor())
                continue

            if (child.parentItemHovered())
                continue

            child.dismissPopup()
        }
    }

    function ensureLayout() {
        _contentItem.ensureLayout()
    }

    function open() {
        control.ensureLayout()
        control.show()
    }

    function popup() {
        control.ensureLayout()
        control.show()
    }

    function popupAt(x, y) {
        control.ensureLayout()
        control.showAt(x, y)
    }

    function popupSubMenu() {
        control.ensureLayout()
        control.show()
    }

    // A submenu closes immediately after the pointer has actually entered
    // and then left it. The timer only covers the short handoff gap between
    // the parent popup and this popup.
    property bool pointerEntered: false

    onPointerInsideChanged: {
        if (!control.submenu || control.keyboardNavigation)
            return

        if (control.pointerInside) {
            pointerEntered = true
        } else if (pointerEntered) {
            pointerEntered = false
            if (!control.containsGlobalCursor() &&
                    !control.parentItemContainsGlobalCursor() &&
                    !control.parentPopupContainsGlobalCursor()) {
                control.dismissPopup()
            }
        }
    }

    onVisibleChanged: {
        if (!visible) {
            _contentItem.resetScroll()
            pointerEntered = false
            keyboardNavigation = false
            setCurrentIndex(-1)
        }
    }

    // Only a backstop for the pointer leaving the menu without a last motion
    // event: updateSubmenuHover() closes a submenu the moment the pointer
    // moves off it.
    property Timer submenuDismissTimer: Timer {
        interval: 50
        repeat: true
        running: control.visible

        onTriggered: {
            if (!control.parentItem) {
                stop()
                return
            }

            // A submenu opened with the arrow keys has no pointer anywhere
            // near it; only hover-opened submenus close on hover leaving.
            if (control.keyboardNavigation)
                return

            if (!control.pointerInside &&
                    !control.parentItemHovered() &&
                    !control.parentItemContainsGlobalCursor()) {
                control.dismissPopup()
            }
        }
    }
}
